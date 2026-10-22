#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'

# Wraps the `comment-checker` PostToolUse hook, which flags every comment it
# finds and offers no way to extend its allow-list. Two kinds of Ruby comment
# are load-bearing here and must not be reported: magic comments, which the
# interpreter reads, and YARD doc blocks, which are how this codebase records
# return contracts.
#
# Exempt lines are blanked rather than deleted so the line numbers in whatever
# the checker does report still point at the real source.
class CommentCheckerHook
  CHECKER = ENV.fetch('COMMENT_CHECKER_BIN', 'comment-checker')

  # Replaces the checker's built-in message, whose "necessary comment" tier
  # lists examples (algorithms, security, performance, regex) broad enough to
  # justify almost anything, so it reads as an invitation to argue rather than
  # to rewrite. Upstream bakes that text in; `--prompt` is the only seam.
  PROMPT = <<~PROMPT
    COMMENT DETECTED

    Comments are a last resort. Work through these in order and act on the first
    one that is true. You must respond to this message every time it appears.

    1. The comment was already in the file and this edit did not write it.
       -> Say so and move on. Do not rewrite untouched code to satisfy this hook.

    2. You wrote this comment.
       -> The comment is evidence the code is not obvious. Fix the code, not the
          prose: rename it, extract it, split it, restructure it until the
          comment has nothing left to say, then delete the comment.
       -> A comment survives only when the code cannot be made to carry the
          point, and only for the WHY: the constraint, the upstream bug, the
          non-obvious consequence of doing it the other way. Never for the WHAT.
          If your comment restates the code, it is the wrong exit.
       -> Explain which of these you did. "It is helpful" and "it explains a
          tricky part" are not reasons to keep a comment; the tricky part is the
          thing to rewrite.

    These rules hold for every later edit too, not just this one.

    {{comments}}
  PROMPT

  # The checker filters BDD markers out as always-allowed before it reports, so
  # they reach Claude only if this wrapper finds them.
  BDD_MESSAGE = <<~MESSAGE
    BDD MARKER COMMENT DETECTED

    `given` / `when` / `then` markers are not an exception. A well-written
    example already reads that way: setup, the call under test, and the
    expectation, separated by blank lines and named by the code. The marker
    labels structure the example should be showing.

    -> Delete the markers. If the phases are not visible once they are gone,
       the example is the thing to restructure — name the subject, pull setup
       into `let`, leave one call and one expectation.

    %<comments>s
  MESSAGE

  RUBY_EXTENSIONS = %w[.rb .rake .gemspec .ru .thor .arb].freeze
  RUBY_FILENAMES = %w[Gemfile Rakefile Guardfile Capfile Podfile Brewfile Fastfile Appfile].freeze

  SOURCE_KEYS = %w[content new_string old_string].freeze

  COMMENT_LINE = /\A\s*#/
  MAGIC_COMMENT = /\A\#\s*(?:-\*-\s*)?
    (?:frozen_string_literal|encoding|coding|warn_indent|shareable_constant_value)\s*:/xi
  YARD_TAG = /\A#\s*@!?[a-z_]+/i
  BDD_MARKER = /\A#\s*(?:given|when|then|arrange|act|assert|when\s*&\s*then)\s*\z/i

  BLOCK = 2

  # @return [Integer] the exit status to hand back to Claude Code
  def call(input = $stdin.read)
    status = forward(exempt(input))
    markers = bdd_markers(input)
    return status if markers.empty?

    $stderr.print(format(BDD_MESSAGE, comments: comments_xml(markers)))
    BLOCK
  end

  # @param input [String] the raw PostToolUse payload
  # @return [Array<Array(String, Integer, String)>] file path, line number and
  #   text of every BDD marker the edit writes
  def bdd_markers(input)
    payload = parse(input)
    tool_input = payload && payload['tool_input']
    return [] unless tool_input.is_a?(Hash) && ruby?(tool_input['file_path'])

    written(tool_input).flat_map { |source| markers_in(source, tool_input['file_path']) }
  end

  # @param input [String] the raw PostToolUse payload
  # @return [String] the payload with exempt comment lines blanked out, or the
  #   input untouched when it is not a payload this hook understands
  def exempt(input)
    payload = parse(input)
    tool_input = payload && payload['tool_input']
    return input unless tool_input.is_a?(Hash) && ruby?(tool_input['file_path'])

    blank_sources(tool_input)
    edits(tool_input).each { |edit| blank_sources(edit) }
    JSON.generate(payload)
  end

  # @param source [String] Ruby source
  # @return [String] the same source with every exempt comment line emptied
  def blank(source)
    lines = source.split("\n", -1)
    exempt_indexes(lines).each { |index| lines[index] = '' }
    lines.join("\n")
  end

  private
    def forward(input)
      _out, err, status = Open3.capture3(CHECKER, '--prompt', PROMPT, stdin_data: input)
      $stderr.print(err)
      status.exitstatus
    rescue Errno::ENOENT
      warn("[comment-checker] Skipping: #{CHECKER} is not installed")
      0
    end

    def written(tool_input)
      sources = [tool_input['content'], tool_input['new_string']]
      sources += edits(tool_input).map { |edit| edit['new_string'] }
      sources.grep(String)
    end

    def markers_in(source, file_path)
      source.split("\n", -1).each_with_index.filter_map do |line, index|
        [file_path, index + 1, line.strip] if line.strip.match?(BDD_MARKER)
      end
    end

    def comments_xml(markers)
      lines = markers.map do |file_path, line_number, text|
        "\t<comment file=\"#{file_path}\" line-number=\"#{line_number}\">#{text}</comment>"
      end
      ['<comments>', *lines, '</comments>'].join("\n")
    end

    def parse(input)
      JSON.parse(input)
    rescue JSON::ParserError
      nil
    end

    def ruby?(file_path)
      return false unless file_path.is_a?(String)

      RUBY_EXTENSIONS.include?(File.extname(file_path)) ||
        RUBY_FILENAMES.include?(File.basename(file_path))
    end

    def edits(tool_input)
      edits = tool_input['edits']
      edits.is_a?(Array) ? edits.grep(Hash) : []
    end

    def blank_sources(hash)
      SOURCE_KEYS.each do |key|
        source = hash[key]
        hash[key] = blank(source) if source.is_a?(String)
      end
    end

    def exempt_indexes(lines)
      blocks(lines).flat_map { |block| exempt_in(block, lines) }
    end

    # Comment lines only count as one block while they are uninterrupted, so a
    # YARD block's prose lines travel with the tags that exempt them.
    def blocks(lines)
      lines.each_index
           .chunk_while { |left, right| comment?(lines[left]) && comment?(lines[right]) }
           .select { |block| comment?(lines[block.first]) }
    end

    def exempt_in(block, lines)
      texts = block.to_h { |index| [index, lines[index].strip] }
      return block if texts.each_value.any? { |text| text.match?(YARD_TAG) }

      texts.select { |_index, text| text.match?(MAGIC_COMMENT) }.keys
    end

    def comment?(line)
      line.match?(COMMENT_LINE)
    end
end

exit CommentCheckerHook.new.call if $PROGRAM_NAME == __FILE__

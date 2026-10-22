# frozen_string_literal: true

require 'json'
require_relative 'comment_checker'

RSpec.describe CommentCheckerHook do
  subject(:hook) { described_class.new }

  describe 'PROMPT' do
    subject(:prompt) { described_class::PROMPT }

    it 'carries the placeholder the checker substitutes the findings into' do
      expect(prompt).to include('{{comments}}')
    end

    it 'offers no tier that keeps a comment for being necessary' do
      expect(prompt).not_to match(/necessary/i)
    end

    it 'offers no tier that keeps a comment for being a BDD marker' do
      expect(prompt).not_to match(/given/i)
    end
  end

  describe '#bdd_markers' do
    let(:payload) do
      { 'tool_name' => 'Write',
        'tool_input' => { 'file_path' => file_path, 'content' => content } }
    end
    let(:file_path) { '/spec/models/plan_spec.rb' }

    context 'with the markers the checker suppresses' do
      let(:content) { "it 'works' do\n  # given\n  a = 1\n  # Then\n  expect(a).to eq(1)\nend\n" }

      it 'reports each one with its line' do
        expect(hook.bdd_markers(JSON.generate(payload)))
          .to eq([[file_path, 2, '# given'], [file_path, 4, '# Then']])
      end
    end

    context 'with the xunit spellings' do
      let(:content) { "# arrange\n# act\n# assert\n" }

      it 'reports those too' do
        expect(hook.bdd_markers(JSON.generate(payload)).map(&:last))
          .to eq(['# arrange', '# act', '# assert'])
      end
    end

    context 'with a comment that merely starts with a marker word' do
      let(:content) { "# given a guest with no plan\nx = 1\n" }

      it 'leaves it to the checker, which already flags it' do
        expect(hook.bdd_markers(JSON.generate(payload))).to be_empty
      end
    end

    context 'with markers in an edit the payload replaces' do
      let(:payload) do
        { 'tool_name' => 'Edit',
          'tool_input' => { 'file_path' => file_path,
                            'old_string' => "# when\nold\n",
                            'new_string' => "# then\nnew\n" } }
      end

      it 'reports only the side being written' do
        expect(hook.bdd_markers(JSON.generate(payload))).to eq([[file_path, 1, '# then']])
      end
    end

    context 'with a non-Ruby file' do
      let(:file_path) { '/spec/thing.py' }
      let(:content) { "# given\n" }

      it 'reports nothing' do
        expect(hook.bdd_markers(JSON.generate(payload))).to be_empty
      end
    end
  end

  describe '#blank' do
    context 'with a magic comment' do
      let(:source) { "# frozen_string_literal: true\n\nclass Thing\nend\n" }

      it 'empties the line but keeps the ones after it in place' do
        expect(hook.blank(source)).to eq("\n\nclass Thing\nend\n")
      end
    end

    context 'with an encoding comment' do
      let(:source) { "# -*- coding: utf-8 -*-\nx = 1\n" }

      it 'empties it' do
        expect(hook.blank(source)).to eq("\nx = 1\n")
      end
    end

    context 'with a YARD block' do
      let(:source) do
        <<~RUBY
          # Answers why the lane is skipped.
          #
          # @param lane [LightningLane] the lane
          # @return [String, nil] the reason
          def reason_for(lane)
          end
        RUBY
      end

      it 'empties the whole block, prose included' do
        expect(hook.blank(source)).to eq("\n\n\n\ndef reason_for(lane)\nend\n")
      end
    end

    context 'with a YARD directive tag' do
      let(:source) { "# @!attribute [r] lane\nattr_reader :lane\n" }

      it 'empties it' do
        expect(hook.blank(source)).to eq("\nattr_reader :lane\n")
      end
    end

    context 'with a plain comment block' do
      let(:source) { "# Adds one to one.\nx = 1 + 1\n" }

      it 'leaves it for the checker to flag' do
        expect(hook.blank(source)).to eq(source)
      end
    end

    context 'with a plain block sitting next to a YARD block' do
      let(:source) do
        <<~RUBY
          # Explains nothing.
          x = 1

          # @return [Integer]
          def two = 2
        RUBY
      end

      it 'only empties the YARD block' do
        expect(hook.blank(source)).to eq("# Explains nothing.\nx = 1\n\n\ndef two = 2\n")
      end
    end

    context 'with a trailing comment that mentions a tag' do
      let(:source) { "x = 1 # @param is not a doc block here\n" }

      it 'leaves it, since only whole-line comments form a block' do
        expect(hook.blank(source)).to eq(source)
      end
    end

    context 'with a magic comment adjacent to a plain comment' do
      let(:source) { "# frozen_string_literal: true\n# Explains nothing.\nx = 1\n" }

      it 'empties only the magic comment' do
        expect(hook.blank(source)).to eq("\n# Explains nothing.\nx = 1\n")
      end
    end
  end

  describe '#exempt' do
    let(:payload) do
      { 'tool_name' => 'Write',
        'tool_input' => { 'file_path' => file_path, 'content' => content } }
    end
    let(:content) { "# frozen_string_literal: true\nx = 1\n" }
    let(:exempted) { JSON.parse(hook.exempt(JSON.generate(payload))) }

    context 'with a Ruby file' do
      let(:file_path) { '/app/models/plan.rb' }

      it 'blanks the exempt lines in the content' do
        expect(exempted.dig('tool_input', 'content')).to eq("\nx = 1\n")
      end
    end

    context 'with a Ruby file that has no extension' do
      let(:file_path) { '/Gemfile' }

      it 'still blanks the exempt lines' do
        expect(exempted.dig('tool_input', 'content')).to eq("\nx = 1\n")
      end
    end

    context 'with a non-Ruby file' do
      let(:file_path) { '/config/deploy.py' }

      it 'passes the payload through untouched' do
        expect(hook.exempt(JSON.generate(payload))).to eq(JSON.generate(payload))
      end
    end

    context 'with an Edit payload' do
      let(:payload) do
        { 'tool_name' => 'Edit',
          'tool_input' => { 'file_path' => '/app/models/plan.rb',
                            'old_string' => "# @return [String]\ndef a = 'a'\n",
                            'new_string' => "# @return [Symbol]\ndef a = :a\n" } }
      end

      it 'blanks both sides so the diff sees neither' do
        expect(exempted['tool_input']).to include('old_string' => "\ndef a = 'a'\n",
                                                  'new_string' => "\ndef a = :a\n")
      end
    end

    context 'with a MultiEdit payload' do
      let(:payload) do
        { 'tool_name' => 'MultiEdit',
          'tool_input' => { 'file_path' => '/app/models/plan.rb',
                            'edits' => [{ 'old_string' => 'a', 'new_string' => "# @return [Symbol]\n:a\n" }] } }
      end

      it 'blanks inside each edit' do
        expect(exempted.dig('tool_input', 'edits', 0, 'new_string')).to eq("\n:a\n")
      end
    end

    context 'with input that is not JSON' do
      it 'passes it through for the checker to reject' do
        expect(hook.exempt('not json')).to eq('not json')
      end
    end

    context 'with a payload carrying no tool_input' do
      it 'passes it through' do
        expect(hook.exempt('{"tool_name":"Bash"}')).to eq('{"tool_name":"Bash"}')
      end
    end
  end
end

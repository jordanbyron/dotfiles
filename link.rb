current_directory = File.dirname(File.expand_path(__FILE__))

dot_files = %w{js ackrc bash_login gitconfig gitignore irbrc todo gemrc
               inputrc synergy freetds.conf git-worktree.zsh zshrc}

dot_files.each do |dot|
  `ln -nfs #{current_directory}/#{dot} ~/.#{dot}`
end

`mkdir -p ~/.config/nvim/lua`

# Linked file by file, not directory by directory: `ln -nfs` given an existing
# real directory writes the link inside it instead of replacing it.
%w{init.vim lua/lsp-config.lua RUBY_LSP_KEYBINDINGS.md}.each do |f|
  `ln -nfs #{current_directory}/nvim/#{f} ~/.config/nvim/#{f}`
end

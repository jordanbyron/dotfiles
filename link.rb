current_directory = File.dirname(File.expand_path(__FILE__))

dot_files = %w{js ackrc bash_login gitconfig gitignore irbrc todo gemrc
               inputrc synergy freetds.conf git-worktree.zsh zshrc}

dot_files.each do |dot|
  `ln -nfs #{current_directory}/#{dot} ~/.#{dot}`
end

`mkdir -p ~/.config/nvim`
`ln -nfs #{current_directory}/nvim/init.vim ~/.config/nvim/init.vim`

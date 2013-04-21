current_directory = File.dirname(File.expand_path(__FILE__))

dot_files = %w{js ackrc bash_login gitconfig gitignore irbrc todo vim vimrc
               gemrc inputrc}

dot_files.each do |dot|
  `ln -nfs #{current_directory}/#{dot} ~/.#{dot}`
end

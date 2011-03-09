current_directory = File.dirname(File.expand_path(__FILE__))

dot_files = %w{js terminitor}

dot_files.each do |dir|
  `ln -nfs #{current_directory}/#{dir} ~/.#{dir}`
end
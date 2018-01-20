# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

big_assets_dir = '/var/data/assets'

unless File.directory?(big_assets_dir)
  STDERR.puts "#{big_assets_dir} directory is missing".red
  raise "#{big_assets_dir} directory is missing"
end

Rails.application.config.assets.paths << Dir.new(big_assets_dir)
Rails.application.config.assets.precompile = [
  Proc.new { |filename, path|
    path =~ /(app\/assets)|(var\/data\/assets)/ &&
    !%w(.js .css).include?(File.extname(filename))
  },
  /application.(css|js)$/
]

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

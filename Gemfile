source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
# gem 'puma', '~> 3.0' # 3.7.0 has a bug at the moment
gem 'puma', '~> 3.6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.3', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
# Use Haml markup language
gem 'haml-rails', '~> 0.9'
gem 'redcarpet'
# Use Bourbon, a mixin library for Sass. Read more: http://bourbon.io
gem 'bourbon', '5.0.0.beta.7'
# Use Neat a css grid framework. Read more: http://neat.bourbon.io
gem 'neat'

gem 'awesome_print'

gem 'font-awesome-sass', '~> 4.7.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Use Rspec behaviour briven bevelopment framework
  # http://www.chrisjmendez.com/2016/08/01/rails-5-testing-using-rspec/
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'spring-commands-rspec'
  gem 'capybara'
  gem 'jasmine'
end

group :test do
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-ctags-bundler'
  gem 'guard-shell'

  # linters
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
end

source 'https://rails-assets.org' do
  gem 'rails-assets-colorbrewer'
  gem 'rails-assets-dcjs'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-fullpage'
  gem 'rails-assets-plotly.js'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# this is an odd dependency that some gem needs
gem 'mini_portile2'

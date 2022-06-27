source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.9'

gem 'rails', '~> 6.0.4', '>= 6.0.4.8'

gem 'active_storage_validations', '>= 0.8.2'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'coderay'
gem 'devise'
gem 'font-awesome-rails'
gem 'friendly_id', '~> 5.4.0'
gem 'image_processing', '>= 1.9.3'
gem 'jbuilder', '~> 2.7'
gem 'kaminari'
gem 'mini_magick', '>= 4.9.5'
gem 'pragmatic_segmenter'
gem 'puma', '~> 4.1'
gem 'rails-i18n'
gem 'ransack'
gem 'redcarpet', '~> 2.3.0'
gem 'sass-rails', '>= 6'
gem 'seed_dump'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.0'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '>= 5.1.2', '< 6.0.0'
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'listen', '>= 3.1.5'
  gem 'rubocop', require: false
  gem 'spring', '>= 2.1.0'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '>= 2.0.1'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :production do
  gem 'pg', '>= 1.1.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

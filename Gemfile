source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.6"

gem "rails", "~> 6.0.4", ">= 6.0.4.8"

gem "active_storage_validations", ">= 0.8.2"
gem "annotate"
gem "bootsnap", ">= 1.4.2", require: false
gem "cancancan"
gem "coderay"
gem "devise"
gem "font-awesome-rails"
gem "friendly_id", "~> 5.4.0"
gem "image_processing", ">= 1.9.3"
gem "jbuilder", "~> 2.7"
gem "kaminari"
gem "mini_magick", ">= 4.9.5"
gem "pg"
gem "pragmatic_segmenter"
gem "puma", "~> 4.1"
gem "rails-i18n"
gem "ransack"
gem "redcarpet", ">= 3.5.1"
gem "sass-rails", ">= 6"
gem "seed_dump"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 5.0"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec_junit_formatter"
  gem "rspec-rails", ">= 5.1.2", "< 6.0.0"
end

group :development do
  gem "bullet"
  gem "htmlbeautifier"
  gem "listen", ">= 3.1.5"
  gem "prettier"
  gem "rails-erd"
  gem "rubocop", require: false
  gem "rubocop-discourse", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rufo"
  gem "spring", ">= 2.1.0"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", ">= 2.0.1"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara"
  gem "clipboard"
  gem "selenium-webdriver"
end

group :production do
  gem "aws-sdk-s3"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", ">= 1.2.10", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

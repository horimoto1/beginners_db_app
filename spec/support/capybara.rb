require "capybara/rspec"
require "selenium-webdriver"

# Capybaraにheadless_chromedriverを登録する
Capybara.register_driver :headless_chromedriver do |app|
  # Chromeをヘッドレスモードで起動するように指定する
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("headless")

  # seleniumでchromedriverを作成する
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: options
  )
end

# Capybaraにchromedriverを登録する
Capybara.register_driver :chromedriver do |app|
  # seleniumでchromedriverを作成する
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome
  )
end

# デフォルトのドライバをheadless_chromedriverにする
Capybara.javascript_driver = :headless_chromedriver

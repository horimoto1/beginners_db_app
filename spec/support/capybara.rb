require "capybara/rspec"
require "selenium-webdriver"

# Capybaraにchromedriverを登録する
Capybara.register_driver :chromedriver do |app|
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

# jsオプション有効時のドライバをchromedriverに変更する
Capybara.javascript_driver = :chromedriver

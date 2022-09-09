require "capybara/rspec"
require "selenium-webdriver"

# ヘッドレスモードのchromedriverを登録する
Capybara.register_driver :headless_selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: options
  )
end

# 通常のchromedriverを登録する
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome
  )
end

# デフォルトのJSドライバをヘッドレスモードに変更する
Capybara.javascript_driver = :headless_selenium

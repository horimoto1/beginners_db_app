require "capybara/rspec"
require "selenium-webdriver"

driver = ENV.fetch("RAILS_WEB_DRIVER") { "chrome" }
puts "Capybara register #{driver} driver"

case driver
when /chrome/i
  # ヘッドレスモードのchromedriverを登録する
  Capybara.register_driver :headless_selenium do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")

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
when /firefox/i
  # ヘッドレスモードのfirefoxdriverを登録する
  Capybara.register_driver :headless_selenium do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument("--headless")

    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox,
      options: options
    )
  end
end

# デフォルトのドライバをヘッドレスモードに変更する
Capybara.javascript_driver = :headless_selenium

Gem::Specification.new do |s|
  s.name          = "screenshot_web_page"
  s.version       = "0.1.0"
  s.authors       = ["Muhammad Nur Annas"]
  s.email         = "annassdan@gmail.com"

  s.summary       = "Screenshot a web page for Rails"
  s.description   = "Screenshot a web page for Rails"
  s.homepage      = "https://github.com/annassdan/screenshot_web_page/screenshot_web_page"
  s.license       = "MIT"

  # Include your Ruby files and bundled binary
  s.files         = Dir["lib/**/*"] + Dir["vendor/chromium/**/*"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.6.0"

  # Add runtime dependencies
  s.add_dependency "puppeteer-ruby", "~> 0.45.6"
  s.add_dependency "rake", ">= 10.0.0"
end
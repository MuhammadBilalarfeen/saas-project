source "https://rubygems.org"

ruby "3.2.2"

# -----------------------------
# Core Rails + Assets
# -----------------------------
gem "rails", "~> 8.0"
gem "sprockets-rails"      # USE THIS — Propshaft removed, Sprockets needed
gem "sassc-rails"          # SCSS compiler
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# -----------------------------
# Bootstrap + jQuery Support
# -----------------------------
gem "jquery-rails"         # jQuery for Bootstrap 3 scripts
gem "bootstrap", "~> 5.3"  # Only CSS used! Do NOT load bootstrap.js via gem.
gem "popper_js"

# -----------------------------
# Authentication
# -----------------------------
gem "devise", "~> 4.9"
gem "devise-bootstrap-views"

# -----------------------------
# Database
# -----------------------------
gem "pg", "~> 1.1"

# -----------------------------
# Web server
# -----------------------------
gem "puma", ">= 5.0"

# -----------------------------
# Utilities
# -----------------------------
gem "jbuilder"
gem "dotenv-rails", groups: [:development, :test]
gem "bootsnap", require: false

# -----------------------------
# Debugging & Development
# -----------------------------
group :development, :test do
  gem "debug", require: "debug/prelude"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

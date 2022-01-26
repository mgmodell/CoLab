# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.4.1'

gem 'puma', '~> 5.0'
# Use mysql as the database for Active Record
#gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'mysql2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Transpile app-like JavaScript. Read more:
# https://github.com/rails/webpacker
gem 'webpacker'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

gem 'activerecord-session_store'
gem 'active_storage_validations'
gem 'ahoy_email'
gem 'aws-sdk-s3'
gem 'bootsnap'
gem 'bourbon'
gem 'chronic'
gem 'city-state'
gem 'country_select'
gem 'd3-rails'
gem 'delayed_job_active_record'
gem 'descriptive_statistics', '~> 2.5.1', require: 'descriptive_statistics/safe'
gem 'devise-multi_email'
gem 'devise_token_auth', git: 'https://github.com/mgmodell/devise_token_auth'
gem 'email_address'
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
gem 'image_processing', '~> 1.0'
gem 'jquery_mobile_rails'
# gem 'kaminari'
gem 'listen'
gem 'net-smtp'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'prawn'
gem 'prawn-table'
gem 'prawn-qrcode'
gem 'rails_12factor', group: :production
gem 'react-rails'
gem 'sassc-rails'
gem 'stopwords-filter', require: 'stopwords'
gem 'traco'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet'
  gem 'byebug'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'ruby-debug-ide'
  gem 'debase', '0.2.5.beta2'
  gem 'htmlbeautifier'
  gem 'htmlentities'
  gem 'i18n_data'
  gem 'paperclip'
  gem 'parallel_tests'
  gem 'railroady'
  gem 'rails-erd', require: false
  gem 'rb-readline'
  gem 'report_builder'
  gem 'rspec'
  gem 'rubocop', '~> 1.25.0', require: false
  gem 'reek'
  gem 'rubocop-thread_safety'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'selenium-webdriver'
  gem 'solargraph'
  gem 'webdrivers', '~> 5.0', require: false
end

group :test do
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

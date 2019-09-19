source 'https://rubygems.org'

plugin "bundler-inject", "~> 1.1"
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem 'jbuilder', '~> 2.0'
gem 'manageiq-loggers', '~> 0.3.0'
gem 'rails', '~> 5.2.2'


gem 'puma', '~> 3.11'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'simplecov'
  gem 'rubocop',             '~>0.69.0', :require => false
  gem 'rubocop-performance', '~>1.3',    :require => false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

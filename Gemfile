source 'https://rubygems.org'

plugin "bundler-inject", "~> 1.1"
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil


gem 'activesupport', '~> 5.2.2'
gem "more_core_extensions"
gem 'puma', '~> 3.11'
gem 'rack', '~> 2.0.7'

group :development, :test do
  gem 'rubocop',             '~>0.69.0', :require => false
  gem 'rubocop-performance', '~>1.3',    :require => false
  gem 'simplecov'
end

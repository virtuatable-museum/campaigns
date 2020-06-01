require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

service = Virtuatable::Application.load!('campaigns')

run Controllers::Campaigns
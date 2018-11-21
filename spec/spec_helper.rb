env_location = File.join(File.dirname(__FILE__), '..', '.env')

system "source #{env_location}"

ENV['RACK_ENV'] = 'test'
ENV['APP_KEY'] = '5bbda7811d41c80b8bb19d54'

require 'bundler'
Bundler.require :test

require './controllers/base.rb'

require 'arkaan/specs'

service = Arkaan::Utils::MicroService.instance
  .register_as('campaigns')
  .from_location(__FILE__)
  .in_test_mode

Arkaan::Specs.include_shared_examples
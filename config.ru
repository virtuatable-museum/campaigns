require 'bundler'
Bundler.require(ENV['RACK_ENV'].to_sym || :development)

require './controllers/base.rb'

$stdout.sync = true

service = Arkaan::Utils::MicroService.instance
  .register_as('campaigns')
  .from_location(__FILE__)
  .in_standard_mode

use Controllers::Files
use Controllers::Invitations
use Controllers::Messages
use Controllers::Campaigns
run Controllers::Commands

at_exit { Arkaan::Utils::MicroService.instance.deactivate! }
# frozen_string_literal: true

module Controllers
  # This controller handles the special messages invoking commands.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Commands < Controllers::Base
    declare_route 'post', '/:id/commands' do
      campaign = check_session_and_campaign(action: 'messages', strict: false)
      check_presence('command', route: 'messages')
      if params['command'].nil? || params['command'].empty?
        custom_error 400, 'messages.command.empty'
      end

      begin
        message = Services::Commands.instance.create(
          params['session_id'],
          campaign,
          params['command'],
          params['content']
        )
        halt 201, { message: 'created', item: message }.to_json
      rescue Services::Exceptions::UnparsableCommand
        custom_error 400, 'commands.content.unparsable'
      rescue Services::Exceptions::UnknownCommand
        custom_error 400, 'commands.command.unknown'
      end
    end
  end
end

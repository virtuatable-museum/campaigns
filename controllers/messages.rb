# frozen_string_literal: true

module Controllers
  # This controller handles classic messages sent in chatrooms.
  # @author vincent Courtois <courtois;vincent@outlook.com>
  class Messages < Controllers::Base
    def service
      Services::Messages.instance
    end

    declare_route 'get', '/:id/messages' do
      campaign = check_session_and_campaign(
        action: 'messages_list',
        strict: false
      )
      halt 200, service.list(session_id, campaign).to_json
    end

    declare_route 'post', '/:id/messages' do
      campaign = check_session_and_campaign(action: 'messages', strict: false)
      check_presence('content', route: 'messages')
      custom_error 400, 'messages.content.empty' if params['content'].empty?

      message = service.create(session_id, campaign, params['content'])
      halt 201, { message: 'created', item: message.to_h }.to_json
    end

    declare_route 'delete', '/:id/messages/:message_id' do
      campaign = check_session_and_campaign(
        action: 'delete_messages',
        strict: false
      )
      message = campaign.messages.where(id: params['message_id']).first
      custom_error 404, 'messages.message_id.unknown' if message.nil?

      unless service.belongs_to?(message, session_id)
        custom_error 403, 'messages.session_id.forbidden'
      end
      message.update_attribute(:deleted, true)
      halt 200, { message: 'deleted' }.to_json
    end
  end
end

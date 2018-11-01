module Controllers
  class Messages < Controllers::Base

    declare_route 'get', '/:id/messages' do
      campaign = check_session_and_campaign(action: 'messages_list', strict: false)
      halt 200, Services::Messages.instance.list(campaign).to_json
    end

    declare_route 'post', '/:id/messages' do
      campaign = check_session_and_campaign(action: 'messages', strict: false)
      check_presence('content', route: 'messages')
      custom_error 400, 'messages.content.empty' if params['content'].empty?

      message = Services::Messages.instance.create(params['session_id'], campaign, params['content'])
      halt 201, {message: 'created', item: message.to_h}.to_json
    end
  end
end
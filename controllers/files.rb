module Controllers
  class Files < Controllers::Base

    declare_route 'get', '/:id/files' do
      _session = check_session('messages')
      _campaign = get_campaign_for(_session, action: 'messages', strict: false)
      files = ::Services::Files.instance.list(_campaign)
      halt 200, files.to_json
    end

    declare_route 'post', '/:id/files' do
      _session = check_session('messages')
      _campaign = get_campaign_for(_session, action: 'messages', strict: false)
      check_presence 'filename', 'content', route: 'files_creation'
      if !is_creator_session?(_session, _campaign)
        custom_error 403, 'files_creation.session_id.forbidden'
      end
      ::Services::Files.instance.create(_session, _campaign, params['filename'], params['content'])
      halt 200, {filename: params['filename']}.to_json
    end

    def is_creator_session?(session, campaign)
      return campaign.invitations.where(account: session.account).first.status_creator?
    end
  end
end
module Controllers
  class Files < Controllers::Base

    declare_route 'post', '/:id/files' do
      _session = check_session('messages')
      _campaign = get_campaign_for(_session, action: 'messages', strict: false)
      check_presence 'filename', 'content', route: 'files_creation'
      ::Services::Files.instance.create(_session, _campaign, params['filename'], params['content'])
      halt 200, {filename: params['filename']}.to_json
    end
  end
end
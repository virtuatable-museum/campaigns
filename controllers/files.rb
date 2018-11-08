module Controllers
  class Files < Controllers::Base

    declare_route 'get', '/:id/files' do
      _session = check_session('messages')
      _campaign = get_campaign_for(_session, action: 'messages', strict: false)
      files = ::Services::Files.instance.list(_campaign)
      halt 200, files.to_json
    end

    declare_route 'post', '/:id/files' do
      check_presence 'name', 'content', route: 'files_creation'
      _session = check_session('messages')
      _campaign = get_campaign_for(_session, 'messages', strict: true)

      file = ::Services::Files.instance.create(_session, _campaign, params)

      if file.save
        if ::Services::Files.instance.store(_campaign, file, params)
          halt 200, Decorators::File.new(file).to_h.to_json
        else
          custom_error 400, 'files_creation.upload.failed'
        end
      else
        model_error file, 'files_creation'
      end
    end
  end
end
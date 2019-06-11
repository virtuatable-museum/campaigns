# frozen_string_literal: true

module Controllers
  # This controller handles the action concerning the files objects and blob.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Files < Controllers::Base
    def service
      Services::Files.instance
    end

    declare_route 'get', '/:id/files/:file_id' do
      session = check_session('files_get')
      campaign = get_campaign_for(session, 'files_get', strict: false)

      if service.campaign_has_file?(campaign, params['file_id'])
        service.get_campaign_file(campaign, params['file_id'])
      else
        custom_error 404, 'files_get.file_id.unknown'
      end
    end

    declare_route 'get', '/:id/files' do
      session = check_session('files_list')
      campaign = get_campaign_for(session, 'files_list', strict: false)
      halt 200, service.list(campaign, session).to_json
    end

    declare_route 'post', '/:id/files' do
      check_presence 'name', 'content', route: 'files_creation'
      session = check_session('files_creation')
      campaign = get_campaign_for(session, 'files_creation', strict: true)

      f = service.create(session, campaign, params['name'], params['content'])

      if f.save
        halt 200, Decorators::File.new(f).to_h.to_json
      else
        model_error f, 'files_creation'
      end
    end

    declare_route 'delete', '/:id/files/:file_id' do
      session = check_session('files_deletion')
      campaign = get_campaign_for(session, 'files_deletion', strict: true)

      if service.campaign_has_file?(campaign, params['file_id'])
        service.delete_campaign_file(campaign, params['file_id'])
        halt 200, { message: 'deleted' }.to_json
      else
        custom_error 404, 'files_deletion.file_id.unknown'
      end
    end

    declare_route 'put', '/:id/files/:file_id' do
      session = check_session('permissions_creation')
      get_campaign_for(session, 'permissions_creation', strict: true)

      file = service.get(params['file_id'])
      if file.nil?
        custom_error 404, 'permissions_creation.file_id.unknown'
      else
        if params.key?('permissions')
          service.update_permissions(file, params['permissions'])
        end
        if params.key?('name')
          file.update_attribute(:name, params['name'])
          file.save
        end
      end
      halt 200, { message: 'updated' }.to_json
    end
  end
end

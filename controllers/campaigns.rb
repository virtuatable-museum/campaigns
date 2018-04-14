module Controllers
  class Campaigns < Arkaan::Utils::Controller

    load_errors_from __FILE__

    declare_route 'get', '/' do
      campaigns = Decorators::Campaign.decorate_collection(Arkaan::Campaign.all.to_a)
      halt 200, {count: Arkaan::Campaign.count, items: campaigns.map(&:to_h)}.to_json
    end

    declare_route 'get', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      custom_error(404, 'informations.campaign_id.unknown') if campaign.nil?
      halt 200, Decorators::Campaign.new(campaign).to_h.to_json
    end

    declare_route 'get', '/:id/invitations' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      custom_error(404, 'invitations.campaign_id.unknown') if campaign.nil? 
      halt 200, Decorators::Campaign.new(campaign).invitations.to_json
    end

    declare_route 'post', '/' do
      check_presence('title', 'creator_id', route: 'creation')
      campaign = Services::Campaigns.instance.build(campaign_params, tags || [])
      if campaign.valid?
        campaign.save
        halt 201, {message: 'created'}.to_json
      else
        model_error(campaign, 'creation')
      end
    end

    declare_route 'put', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      custom_error(404, 'update.campaign_id.unknown') if campaign.nil?
      
      if Services::Campaigns.instance.update(campaign, campaign_params, tags)
        halt 200, {message: 'updated'}.to_json
      else
        model_error(campaign, 'update')
      end
    end

    declare_route 'delete', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      custom_error(404, 'deletion.campaign_id.unknown') if campaign.nil?
      campaign.delete
      halt 200, {message: 'deleted'}.to_json
    end

    def campaign_params
      params.select do |key, value|
        ['title', 'description', 'is_private', 'creator_id'].include?(key)
      end
    end

    def tags
      return params['tags'].nil? ? nil : params['tags'].select { |tag| tag != '' }
    end
  end
end
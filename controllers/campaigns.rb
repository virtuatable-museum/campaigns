module Controllers
  class Campaigns < Arkaan::Utils::Controller
    declare_route 'get', '/' do
      campaigns = Decorators::Campaign.decorate_collection(Arkaan::Campaign.all.to_a)
      halt 200, {count: Arkaan::Campaign.count, items: campaigns.map(&:to_h)}.to_json
    end

    declare_route 'get', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      if campaign.nil?
        halt 404, {message: 'campaign_not_found'}.to_json
      else
        halt 200, Decorators::Campaign.new(campaign).to_h.to_json
      end
    end

    declare_route 'post', '/' do
      check_presence 'title', 'creator_id'
      campaign = Services::Campaigns.instance.build(campaign_params, tags || [])
      if campaign.save
        halt 201, {message: 'created'}.to_json
      else
        halt 422, {errors: campaign.errors.messages.values.flatten}.to_json
      end
    end

    declare_route 'put', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      if campaign.nil?
        halt 404, {message: 'campaign_not_found'}.to_json
      else
        if Services::Campaigns.instance.update(campaign, campaign_params, tags)
          halt 200, {message: 'updated'}.to_json
        else
          halt 422, {errors: campaign.errors.messages.values.flatten}.to_json
        end
      end
    end

    declare_route 'delete', '/:id' do
      campaign = Arkaan::Campaign.where(id: params['id']).first
      if campaign.nil?
        halt 404, {message: 'campaign_not_found'}.to_json
      else
        campaign.delete
        halt 200, {message: 'deleted'}.to_json
      end
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
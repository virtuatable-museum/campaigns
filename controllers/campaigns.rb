# frozen_string_literal: true

module Controllers
  # This class is the controller for the campaigns themselves,
  # handling actions on their body and not their subobjects.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Campaigns < Virtuatable::Controllers::Base
    api_route 'get', '/' do
      campaigns = Services::Campaigns.instance.list(session)
      halt 200, { count: campaigns.count, items: campaigns }.to_json
    end

    # declare_route 'get', '/creations' do
    #   session = check_session('own_list')
    #   invitations = session.account.invitations.where(enum_status: :creator)
    #   campaigns = invitations.map(&:campaign)
    #   decorated = Decorators::Campaign.decorate_collection(campaigns)
    #   items = decorated.map(&:to_creator_h)
    #   halt 200, { count: campaigns.count, items: items }.to_json
    # end

    # declare_route 'get', '/:id' do
    #   campaign = check_session_and_campaign(
    #     action: 'informations',
    #     strict: false
    #   )
    #   halt 200, Decorators::Campaign.new(campaign).to_h.to_json
    # end

    api_route 'post', '/' do
      check_presence('title')
      Services::Campaigns.instance.build(session, campaign_params, tags || [])
      halt 201, { message: 'created' }.to_json
    end

    # declare_route 'put', '/:id' do
    #   campaign = check_session_and_campaign(action: 'update')
    #   if Services::Campaigns.instance.update(campaign, campaign_params, tags)
    #     halt 200, { message: 'updated' }.to_json
    #   else
    #     model_error(campaign, 'update')
    #   end
    # end

    api_route 'delete', '/:id' do
      Services::Campaigns.instance.delete(campaign)
      halt 200, { message: 'deleted' }.to_json
    end

    # Returns the parameters allowed to create or update a campaign.
    # @return [Hash] the parameters allowed in the edition
    #   or creation of a campaign.
    def campaign_params
      params.select do |key, _|
        %w[title description is_private max_players].include?(key)
      end
    end

    def tags
      return [] if params['tags'].nil?

      params['tags'].reject(&:empty?)
    end

    def campaign
      campaign = Arkaan::Campaign.find(params['id'])
      api_not_found('campaign_id') if campaign.nil?
      api_forbidden('session_id') if campaign.creator != account
      campaign
    end
  end
end

require 'singleton'

module Services
  # The campaigns service wraps methods such as the creation of a campaign.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Campaigns
    include Singleton

    # Builds a new campaign with the given parameters and tags, updating the tags counters.
    # @param parameters [Hash] the parameters to build the campaign with.
    # @param tags [Array<String>] and array of string tags to identify the content of the campaign.
    def build(parameters, tags)
      campaign = Decorators::Campaign.new(Arkaan::Campaign.new(parameters))
      campaign.assign_tags(tags.uniq)
      return campaign
    end

    def update(campaign, parameters, tags)
      campaign = Decorators::Campaign.new(campaign)
      parameters.each do |key, value|
        campaign[key] = value
      end
      if !tags.nil?
        campaign.delete_tags
        campaign.assign_tags(tags.uniq)
      end
      return campaign.save
    end

    def delete(campaign)
      campaign.invitations.each do |invitation|
        invitation.delete
      end
      return campaign.delete
    end

    def list(session)
      blocked_invitations = Arkaan::Campaigns::Invitation.where(account: session.account, enum_status: :blocked)
      blocked_campaign_ids = blocked_invitations.pluck(:campaign_id)
      campaigns = Arkaan::Campaign.where(is_private: false).not.where(creator: session.account).where(:_id.nin => blocked_campaign_ids)
      decorated = Decorators::Campaign.decorate_collection(campaigns).map { |decorator| decorator.with_invitations(session) }
      return decorated
    end
  end
end
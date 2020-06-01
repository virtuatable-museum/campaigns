# frozen_string_literal: true

module Services
  # The campaigns service wraps methods such as the creation of a campaign.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Campaigns
    include Singleton

    # Builds a new campaign with the given parameters and tags,
    #   updating the tags counters.
    # @param parameters [Hash] the parameters to build the campaign with.
    # @param tags [Array<String>] and array of string tags to identify the
    #   content of the campaign.
    def build(parameters, tags)
      session_id = parameters.delete('session_id')
      creator = Arkaan::Authentication::Session.where(token: session_id).first.account
      campaign = Decorators::Campaign.new(Arkaan::Campaign.new(parameters))
      campaign.creator = creator
      campaign.assign_tags(tags.uniq)
      campaign
    end

    # Updates a given campaign with the provided parameters and tags.
    # @param campaign [Arkaan::Campaign] the campaign to update
    # @param parameters [Hash] an associated array of fields to update
    #   on the campaign.
    # @param tags [Array<String>] an array of tags to put in the campaign.
    #   It ERASES the previous list of tags and replaces it.
    # @return [Boolean] TRUE if the campaign has successfully been updated,
    #   FALSE otherwise.
    def update(campaign, parameters, tags)
      campaign = Decorators::Campaign.new(campaign)
      parameters.each do |key, value|
        campaign[key] = value
      end
      unless tags.nil?
        campaign.delete_tags
        campaign.assign_tags(tags.uniq)
      end
      campaign.save
    end

    # Deletes an existing campaign and its invitations.
    # @param campaign [Arkaan::Campaign] the campaign you want to delete.
    # @return [Boolean] TRUE if the deletion has been successfully done,
    #   FALSE otherwise.
    def delete(campaign)
      campaign.files.pluck(:_id).each do |file_id|
        Services::Files.instance.delete_campaign_file(campaign, file_id)
      end
      campaign.invitations.each(&:delete)
      campaign.delete
    end

    # Gets the list of campaigns available for the account of the given session.
    # An account can access two types of campaigns :
    # 1. The campaigns he has an invitation in, where the status is NOT blocked.
    # 2. The public campaigns (is_private: false) he has either :
    #    - NO invitation in
    #    - an invitation that has a status that is NOT blocked
    # @param [Arkaan::Authentication::Session] the session associated with the
    #   account you want the list of campaigns.
    # @return [Array<Decorators::Campaign>] the list of campaigns.
    def list(session)
      blocked_campaign_ids = invitations(session, :blocked).pluck(:campaign_id)
      created_campaigns_ids = invitations(session, :creator).pluck(:campaign_id)

      campaigns = Arkaan::Campaign.where(
        is_private: false,
        :_id.nin => (blocked_campaign_ids + created_campaigns_ids)
      )

      campaigns.map(&:enhance).map do |decorator|
        decorator.with_invitations(session)
      end
    end

    def invitations(session, status)
      parameters = { account: session.account, enum_status: status }
      Arkaan::Campaigns::Invitation.where(parameters)
    end
  end
end

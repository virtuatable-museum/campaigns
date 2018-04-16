module Services
  class Permissions
    include Singleton

    # Checks if the given session is authorized to see the given campaign's informations. A user can see a campaign if :
    # - This campaign is public (campaign.is_private == false) OR
    # - The user has created the campaign (campaign.creator == session.account) OR
    # - The user has a pending or an accepted invitation in the campaign.
    # @param campaign [Arkaan::Campaign] the campaign to check the authorization on.
    # @param session [Arkaan::Authentication::Session] the session to check the access of.
    # @return [Boolean] TRUE if the session is authorized to access the campaign, FALSE otherwise.
    def authorized?(campaign, session)
      return true if !campaign.is_private
      return true if campaign.creator.id == session.account.id
      invitation = Arkaan::Campaigns::Invitation.where(account: session.account, campaign: campaign).first
      return true if !invitation.nil?
      return false
    end
  end
end
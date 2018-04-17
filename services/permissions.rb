module Services
  class Permissions
    include Singleton

    # Checks if the given session is authorized to see the given campaign's informations. A user can see a campaign if :
    # - This campaign is public (campaign.is_private == false) OR
    # - The user has created the campaign (campaign.creator == session.account) OR
    # - The user has a pending or an accepted invitation in the campaign.
    #
    # @param campaign [Arkaan::Campaign] the campaign to check the authorization on.
    # @param session [Arkaan::Authentication::Session] the session to check the access of.
    # @param strict [Boolean] TRUE to NOT check the invitation, FALSE to check in the invitations if the user can access the campaign.
    #
    # @return [Boolean] TRUE if the session is authorized to access the campaign, FALSE otherwise.
    def authorized?(campaign, session, strict:)
      return true if !campaign.is_private
      return true if campaign.creator.id == session.account.id
      # If NOT in strict mode, we search for an invitation in the campaign to match the user.
      if !strict
        invitation = Arkaan::Campaigns::Invitation.where(account: session.account, campaign: campaign).first
        return true if !invitation.nil?
      end
      return false
    end
  end
end
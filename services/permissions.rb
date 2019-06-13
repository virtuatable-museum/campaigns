# frozen_string_literal: true

module Services
  # Services handling the permission of a player to access a campaign.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Permissions
    include Singleton

    # Checks if the given session is authorized to see the given campaign's
    # informations. A user can see a campaign if either :
    # - This campaign is public (campaign.is_private == false)
    # - The user has created the campaign (campaign.creator == session.account)
    # - The user has a pending or an accepted invitation in the campaign.
    #
    # @param campaign [Arkaan::Campaign] the campaign to check the authorization
    # @param session [Arkaan::Authentication::Session] the session to
    #   check the access of.
    # @param strict [Boolean] TRUE to NOT check the invitation, FALSE to
    #   check in the invitations if the user can access the campaign.
    #
    # @return [Boolean] TRUE if the session is authorized to access the campaign
    #   and FALSE otherwise.
    def authorized?(campaign, session, strict:)
      return true unless campaign.is_private
      return true if campaign.creator.id == session.account.id
      return true if !strict && invited?(session, campaign)

      false
    end

    private

    # Checks if a user identified by a session is invited in a campaign.
    # @param session [Arkaan::Authentication::Session] the session of the user
    # @param campaign [Arkaan::Campaign] the campaign to check.
    # @return [Boolean] TRUE if the user is invited, FALSE otherwise.
    def invited?(session, campaign)
      invitations = Arkaan::Campaigns::Invitation.where(
        account: session.account,
        campaign: campaign
      )
      !invitations.first.nil?
    rescue StandardError
      false
    end
  end
end

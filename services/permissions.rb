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

    # Parses the permissions, only returning the valid ones,
    # and transforming the invitations IDs in invitations.
    #
    # @param permissions [Array<Hash>] the raw permissions to filter
    #   and transform.
    # @return [Array<Hash>] an array of hashes responding to
    #   the :invitation and :level methods.
    def parse(permissions)
      filter_permissions(permissions).map do |permission|
        perm_id = permission['invitation_id']
        invitation = Arkaan::Campaigns::Invitation.where(id: perm_id).first
        check_invitation_existence!(invitation)
        { invitation: invitation, level: get_level(permission) }
      end
    end

    private

    def filter_permissions(permissions)
      permissions.select { |perm| invitation_id?(perm) }
    end

    def invitation_id?(permission)
      permission.is_a?(Hash) && permission.key?('invitation_id')
    end

    def get_level(permission)
      permission['level'].to_sym
    rescue StandardError
      :read
    end

    def check_invitation_existence!(invitation)
      return unless invitation.nil?

      raise Arkaan::Utils::Errors::NotFound.new(
        action: 'permissions_creation',
        field: 'invitation_id',
        error: 'unknown'
      )
    end

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

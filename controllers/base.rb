# frozen_string_literal: true

module Controllers
  # Base controller class subclassed by all the other controllers,
  # providing the different useful methods.
  # @author vincent Courtois <courtois.vincent@outlook.com>
  class Base < Arkaan::Utils::Controllers::Checked
    load_errors_from __FILE__

    # Returns the parameters allowed to create or update a campaign.
    # @return [Hash] the parameters allowed in the edition
    #   or creation of a campaign.
    def campaign_params
      params.select do |key, _|
        %w[title description is_private creator_id max_players].include?(key)
      end
    end

    # Checks several parameters about the session and the campaign :
    # - the session ID must be given
    # - the session must be found in the database
    # - the campaign must be found in the database
    # - the user must be authorized to act on the campaign.
    # To be authorized to to act on a campaign, the user :
    # - must have created it in strict mode
    # - must have created it or be invited in it,
    #   or the campaign be public in not strict mode.
    #
    # @param action [String] the path to the errors in the errors config file.
    # @param strict [Boolean] TRUE to use strict mode, FALSE otherwise.
    #
    # @return [Arkaan::Campaign] the campaign found, where the user has access.
    def check_session_and_campaign(action:, strict: true)
      session = check_session(action)
      campaign = get_campaign_for(session, action, strict: strict)
      campaign
    end

    # Checks if the session ID is given, and the session currently existing.
    # @param action [String] the category in the configuration file
    #   to find the errors for the session.
    # @return [Arkaan::Authentication::Session] the session found for this ID.
    def check_session(action)
      check_presence('session_id', route: action)
      token = params['session_id']
      session = Arkaan::Authentication::Session.where(token: token).first
      custom_error(404, "#{action}.session_id.unknown") if session.nil?
      session
    end

    # Gets the campaign for the session, checking its privilege to access it.
    # See the :check_session_and_campaign above for details about permissions.
    #
    # @param session [Arkaan::Authentication::Session] the session to check.
    # @param action [String] the category in the configuration file
    #   to find the errors for the session.
    # @param strict [Boolean] TRUE to use strict mode, FALSE otherwise.
    #
    # @return [Arkaan::Campaign] the campaign found, where the user has access.
    def get_campaign_for(session, action, strict: false)
      campaign = Arkaan::Campaign.where(id: params['id']).first
      service = Services::Permissions.instance
      custom_error(404, "#{action}.campaign_id.unknown") if campaign.nil?
      unless service.authorized?(campaign, session, strict: strict)
        custom_error(403, "#{action}.session_id.forbidden")
      end
      campaign
    end

    def tags
      params['tags'].nil? ? nil : params['tags'].reject { |tag| tag == '' }
    end

    def session_id
      params['session_id']
    end

    # Returns the currently connected player, associated to the
    # session requesting the route.
    # @return [Arkaan::Campaigns::Invitation] the invitation of the currently conencted player.
    def current_player
      campaign = Arkaan::Campaign.where(id: params['id']).first
      campaign.invitations.where(account: session.account).first
    end
  end
end

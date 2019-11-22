module Controllers
  # A sheet is the representation of a character associated to a player 
  class Characters < Controllers::Base
    # We don't get a sheet via its unique ID as a player
    # should only be able to see only his/her sheet.
    declare_route 'get', '/' do
    end

    # The creation, edition and deletion routes should
    # only be accessible to the game master of the campaign.
    declare_route 'post', '/:id/characters' do
      check_presence 'data', 'invitation_id', route: 'create_character'
      campaign = check_session_and_campaign(action: 'create_sheet')
      session = Arkaan::Authentication::Session.where(token: params['session_id']).first
      if session.account.id != campaign.creator.id
        custom_error 403, 'character_creation.session_id.forbidden'
      end
      invitation = campaign.invitations.where(id: params['invitation_id']).first
      if invitation.nil?
        custom_error 404, 'character_creation.invitation_id.unknown'
      end
      valid = Services::Characters.instance.validate(invitation, data)
      if valid
        character = Services::Characters.instance.create(invitation, data)
        halt 201, data.to_json
      else
        custom_error 400, 'character_creation.data.validation'
      end
    end
    declare_route 'put', '/:id' do

    end
    declare_route 'delete', '/:id' do

    end

    def data
      JSON.parse(params['data'])
    end
  end
end
module Controllers
  class Invitations < Controllers::Base

    declare_route 'get', '/:id/invitations' do
      campaign = check_session_and_campaign(action: 'invitations', strict: false)
      invitations = campaign.invitations.order_by(status: :asc)
      halt 200, Decorators::Invitation.decorate_collection(invitations).map(&:to_simple_h).to_json
    end
  end
end
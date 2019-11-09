# frozen_string_literal: true

module Controllers
  # This controller handles links between campaigns and players.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Invitations < Controllers::Base
    declare_route 'get', '/:id/invitations' do
      campaign = check_session_and_campaign(
        action: 'invitations',
        strict: false
      )
      invitations = campaign.invitations.order_by(status: :asc)
      decorated = Decorators::Invitation.decorate_collection(invitations)
      halt 200, decorated.map(&:to_simple_h).to_json
    end
  end
end

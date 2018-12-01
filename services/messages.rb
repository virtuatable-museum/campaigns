module Services
  # Service used to create players messages in cammpaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Messages
    include Singleton

    def list(session_id, campaign)
      player = get_player(session_id, campaign)
      messages = campaign.messages
      if player.account.id.to_s != campaign.creator.id.to_s
        messages = messages.excludes('data.command' => 'roll:secret')
        messages = messages.to_a + messages.where(enum_type: 'command', 'data.command' => 'roll:secret', player_id: player.id.to_s).to_a
      end
      return Decorators::Message.decorate_collection(messages.to_a).map(&:to_h)
    end

    def create(session_id, campaign, content)
      return Decorators::Message.new(
        Arkaan::Campaigns::Message.create({
          campaign: campaign,
          player: player,
          enum_type: 'text',
          data: {
            content: content
          }
        })
      )
    end

    private

    def get_player(session_id, campaign)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      return session.account.invitations.where(campaign: campaign).first
    end
  end
end
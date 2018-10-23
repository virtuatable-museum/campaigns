module Services
  # Service used to create players messages in cammpaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Messages
    include Singleton

    def list(campaign)
      return Decorators::Message.decorate_collection(campaign.messages).map(&:to_h)
    end

    def create(session_id, campaign, content)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      player = session.account.invitations.where(campaign: campaign).first

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
  end
end
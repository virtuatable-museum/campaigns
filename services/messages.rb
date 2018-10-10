module Services
  # Service used to create players messages in cammpaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Messages
    include Singleton

    def create(session_id, campaign, content)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      player = session.account.invitations.where(campaign: campaign).first
      message = Arkaan::Campaigns::Message.create(campaign: campaign, content: content, player: player)
      
      return message
    end
  end
end
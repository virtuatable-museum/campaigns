module Services
  class Messages
    include Singleton

    def create(session_id, campaign, content)
      account = Arkaan::Authentication::Session.where(token: session_id).first.account
      player = account.invitations.where(campaign: campaign).first
      message = Arkaan::Campaigns::Message.create(campaign: campaign, content: content, player: player)
      
      return message
    end
  end
end
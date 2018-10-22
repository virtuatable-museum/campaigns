module Services
  # Service used to create players messages in cammpaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Messages
    include Singleton

    attr_reader :diceroll_regex

    def initialize
      @diceroll_regex = /^\/roll ([0-9]+)(d|D)([0-9]+)(\+([0-9]+))?$/
    end

    def list(campaign)
      return campaign.messages.map do |message|
        if message._type == 'Arkaan::Campaigns::Messages::Diceroll'
          Decorators::Messages::Diceroll.new(message).to_h
        else
          Decorators::Messages::Text.new(message).to_h
        end
      end
    end

    def create(session_id, campaign, content)

      session = Arkaan::Authentication::Session.where(token: session_id).first
      player = session.account.invitations.where(campaign: campaign).first

      matches = content.match diceroll_regex

      if matches.nil?
        return Decorators::Messages::Text.new(
          Arkaan::Campaigns::Messages::Text.create({
            campaign: campaign,
            content: content,
            player: player
          })
        )
      else
        return Decorators::Messages::Diceroll.new(
          Arkaan::Campaigns::Messages::Diceroll.create({
            campaign: campaign,
            player: player,
            number_of_dices: matches[1],
            number_of_faces: matches[3],
            modifier: matches[5]
          })
        )
      end
    end
  end
end
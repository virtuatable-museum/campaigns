module Services
  # Service used to create players Commandsnds (eq /roll) in campaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Commands
    include Singleton

    attr_reader :abbreviations

    def initialize
      @abbreviations = {'r' => 'roll', 'rs' => 'roll:secret'}
    end

    def create(session_id, campaign, command, content)
      # Parses the eventually abbreviated form of the command in the normal form.
      command = abbreviations.fetch(command, command)
      
      if ['roll', 'roll:secret'].include? command
        results, modifier = Services::Command::Roll.instance.execute(content)
        return get_message_from(campaign, session_id, {
          command: command,
          modifier: modifier,
          rolls: results
        })
      else
        raise Services::Exceptions::UnknownCommand.new
      end
    end

    private

    # Gets the message hash from the given parameters.
    # @param campaign [Arkaan::Campaign] the campaign in which the message is emitted.
    # @param session [Arkaaan::Authentication::Session] the session of the player emitting the message.
    # @param data [Hash] the additionnal data added to the message.
    # @return [Hash] the Hash representation of the message.
    def get_message_from(campaign, session, data)
      return Decorators::Message.new(
        Arkaan::Campaigns::Message.create({
          campaign: campaign,
          player: invitation(campaign, session),
          enum_type: 'command',
          data: data
        })
      ).to_h
    end

    # Gets the invitation for a player in a campaign
    # @param campaign [Arkaan::Campaign] the campaign in which the invitation has been issued.
    # @param session [Arkaan::Authentication::Session] the session of the player linked to the invitation.
    # @return [Arkaan::Campaigns::Invitation] the invitation of the player in this campaign.    
    def invitation(campaign, session_id)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      return session.account.invitations.where(campaign: campaign).first
    end
  end
end
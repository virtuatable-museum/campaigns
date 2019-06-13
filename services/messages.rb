# frozen_string_literal: true

module Services
  # Service used to create players messages in cammpaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Messages
    include Singleton

    # Lists the messages a user can display in its chatroom for this campaign.
    # @param session_id [String] the unique identifier of the session for the
    #   user trying to get its messages list.
    # @param campaign [Arkaan::Campaign] the campaign from which the user wants
    #   the chatroom from.
    # @return [Array<Arkaan::campaigns::Message>] the messages the user is
    #   allowed to see in this campaign.
    def list(session_id, campaign)
      player = get_player(session_id, campaign)
      messages = campaign.messages
      unless creator?(player, campaign)
        messages = messages.excludes('data.command' => 'roll:secret')
        messages = messages.to_a + secret_rolls_for(player, messages).to_a
      end
      Decorators::Message.decorate_collection(messages.to_a).map(&:to_h)
    end

    # Creates a text message for this user, with the given content.
    # @param session_id [String] the unique identifier of the user
    #   creating the message.
    # @param campaaign [Arkaan::campaign] the campaign in which the message
    #   will be created.
    # @param content [String] the text content of the message to create.
    # @return [Decorators::Message] the decorated message to return as a
    #   result of the creation request.
    def create(session_id, campaign, content)
      Decorators::Message.new(
        Arkaan::Campaigns::Message.create(
          campaign: campaign,
          player: get_player(session_id, campaign),
          enum_type: 'text',
          data: { content: content }
        )
      )
    end

    # Checks if the message correctly belongs to the given user so that he can
    # modify or delete it.
    #
    # @param message [Arkaan::campaigns::Message] the message to check
    #   for this user.
    # @param session_id [String] the unique identifier of the user checking
    #   for its right on the message.
    # @return [Boolean] TRUE if the message was sent by the user, FALSE if not
    def belongs_to?(message, session_id)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      !session.nil? && session.account.id == message.player.account.id
    end

    private

    def creator?(invitation, campaign)
      invitation.account.id.to_s == campaign.creator.id.to_s
    end

    def get_player(session_id, campaign)
      session = Arkaan::Authentication::Session.where(token: session_id).first
      session.account.invitations.where(campaign: campaign).first
    end

    def secret_rolls_for(player, messages)
      messages.where(
        enum_type: 'command',
        'data.command' => 'roll:secret',
        player_id: player.id.to_s
      )
    end
  end
end

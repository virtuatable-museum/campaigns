module Services
  # Service used to create players Commandsnds (eq /roll) in campaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Commands
    include Singleton

    attr_reader :diceroll_regex

    def initialize
      @diceroll_regex = /^([0-9]+)(d|D)([0-9]+)(\+([0-9]+))?$/
    end

    def create(session_id, campaign, command, content)

      case command
      when 'roll'
        matches = content.match diceroll_regex

        if matches.nil?
          raise Services::Exceptions::UnparsableCommand.new
        else
          session = Arkaan::Authentication::Session.where(token: session_id).first
          player = session.account.invitations.where(campaign: campaign).first
          results = []
          matches[1].to_i.times { results << rand(matches[3].to_i) + 1 }

          return Decorators::Message.new(
            Arkaan::Campaigns::Message.create({
              campaign: campaign,
              player: player,
              enum_type: 'command',
              data: {
                command: command,
                number_of_dices: matches[1].to_i,
                number_of_faces: matches[3].to_i,
                modifier: matches[5].to_i,
                results: results
              }
            })
          )
        end
      end
    end
  end
end
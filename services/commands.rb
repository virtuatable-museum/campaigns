module Services
  # Service used to create players Commandsnds (eq /roll) in campaigns chatrooms.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Commands
    include Singleton

    attr_reader :diceroll_regex

    attr_reader :single_roll_regex

    def initialize
      @diceroll_regex = /^([0-9]+((d|D)[0-9]+)?)(\+([0-9]+((d|D)[0-9]+)?))*$/
      @single_roll_regex = /^[0-9]+(d|D)[0-9]+$/
    end

    def create(session_id, campaign, command, content)

      case command
      when 'easteregg'
        return 'easter egg to test'
      when 'roll'
        matches = content.match diceroll_regex

        if matches.nil?
          raise Services::Exceptions::UnparsableCommand.new
        else
          session = Arkaan::Authentication::Session.where(token: session_id).first
          player = session.account.invitations.where(campaign: campaign).first

          results = []
          modifier = 0

          tmp_rolls = content.split('+')
          tmp_rolls.each do |tmp_roll|
            if tmp_roll.match(single_roll_regex).nil?
              modifier += tmp_roll.to_i
            else
              roll_elements = tmp_roll.downcase.split('d')
              roll_results = {
                number_of_dices: roll_elements[0].to_i,
                number_of_faces: roll_elements[1].to_i,
                results: []
              }

              roll_results[:number_of_dices].times {
                roll_results[:results] << rand(roll_results[:number_of_faces]) + 1
              }

              results << roll_results
            end
          end

          return Decorators::Message.new(
            Arkaan::Campaigns::Message.create({
              campaign: campaign,
              player: player,
              enum_type: 'command',
              data: {
                command: command,
                modifier: modifier,
                rolls: results
              }
            })
          ).to_h
        end
      else
        raise Services::Exceptions::UnknownCommand.new
      end
    end
  end
end
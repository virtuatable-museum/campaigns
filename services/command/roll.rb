module Services
  module Command
    # This service executes dice rolls for the players.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class Roll
      include Singleton

      def initialize
        @diceroll_regex = /^([0-9]+((d|D)[0-9]+)?)(\+([0-9]+((d|D)[0-9]+)?))*$/
        @single_roll_regex = /^[0-9]+(d|D)[0-9]+$/
      end

      # Rolls each dices of the content of the dice command.
      # @param content [String] a String formatted as a dice roll.
      def execute(content)
        raise Services::Exceptions::UnparsableCommand.new if incorrect_roll?(content)

        results, modifier = [], 0

        content.split('+').each do |roll|
          if is_modifier?(roll)
            modifier += roll.to_i
          else
            roll_array = roll.downcase.split('d')
            dices = roll_array[0].to_i
            faces = roll_array[1].to_i

            results << {
              number_of_dices: dices,
              number_of_faces: faces,
              results: Array.new(dices).map { rand(faces) + 1 }
            }
          end
        end

        return results, modifier
      end

      private

      # Determines if the roll has the correct format for a dice roll.
      # @param content [String] the content to check.
      # @return [Boolean] TRUE if the roll has an incorrect format, FALSE otherwise.
      def incorrect_roll?(content)
        return content.match(/^([0-9]+((d|D)[0-9]+)?)(\+([0-9]+((d|D)[0-9]+)?))*$/).nil?
      end

      # Checks if the given roll is part of the modifier (just a number) or a dice roll (<number>(d|D)<number>, eg 1d20)
      # @param roll [String] the roll to check
      # @return [Boolean] TRUE if the roll is a modifier, else otherwise.
      def is_modifier?(roll)
        return roll.match(/^[0-9]+(d|D)[0-9]+$/).nil?
      end
    end
  end
end
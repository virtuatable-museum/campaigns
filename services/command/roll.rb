# frozen_string_literal: true

module Services
  module Command
    # This service executes dice rolls for the players.
    # @author Vincent Courtois <courtois.vincent@outlook.com>
    class Roll
      include Singleton

      # @!attribute [r] diceroll_regex
      #   @return [Regexp] the regular expression to identify dices.
      attr_reader :diceroll_regex
      # @!attribute [r] modifier_regex
      #   @return [Regexp] the regular expression to identify modifiers.
      attr_reader :modifier_regex

      def initialize
        @diceroll_regex = /^([0-9]+((d|D)[0-9]+)?)(\+([0-9]+((d|D)[0-9]+)?))*$/
        @modifier_regex = /^[0-9]+(d|D)[0-9]+$/
      end

      # Rolls each dices of the content of the dice command.
      # @param content [String] a String formatted as a dice roll.
      def execute(command, content)
        check_parsability!(content)
        content_array = content.split('+')

        {
          command: command,
          rolls: results(content_array),
          modifier: modifier(content_array)
        }
      end

      private

      # Checks if a command is parsable and raises an error if its not.
      # @raise [Services::Exceptions::UnparsableCommand]
      def check_parsability!(content)
        raise unparsable, 'Unparsable command' if incorrect_roll?(content)
      end

      # Returns the unparsable exception class when a command can't be parsed.
      # @return [Class] the class object for the unparsable error.
      def unparsable
        Services::Exceptions::UnparsableCommand
      end

      # Gets the sum of the modifiers for the rolls array.
      # Dices are ignored and modifiers are sumed.
      # @param rolls [Array<String>] the rolls (dices and modifiers) to sum.
      def modifier(rolls)
        rolls.inject(0) do |sum, roll|
          modifier?(roll) ? sum + roll.to_i : sum
        end
      end

      # Gets the sum of the dices for the rolls array.
      # Modifiers are ignored, rolls are resolved.
      # @param rolls [Array<String>] the rolls (dices and modifiers) to sum
      def results(rolls)
        rolls.inject([]) do |arr, roll|
          modifier?(roll) ? arr : arr << resolve_dice(roll)
        end
      end

      # Resolves a dice roll by fixing its output value in its own interval.
      # @param roll [String] a roll of the form <n_dices>D<n_faces>
      # @return [Hash] a data structure with the results.
      def resolve_dice(roll)
        roll_array = roll.downcase.split('d')
        dices = roll_array[0].to_i
        faces = roll_array[1].to_i

        {
          number_of_dices: dices,
          number_of_faces: faces,
          results: Array.new(dices).map { rand(faces) + 1 }
        }
      end

      # Determines if the roll has the correct format for a dice roll.
      # @param content [String] the content to check.
      # @return [Boolean] TRUE if the roll has an incorrect format,
      #   FALSE otherwise.
      def incorrect_roll?(content)
        content.match(diceroll_regex).nil?
      end

      # Checks if the given roll is part of the modifier (just a number)
      # or a dice roll (<number>(d|D)<number>, eg 1d20)
      #
      # @param roll [String] the roll to check
      # @return [Boolean] TRUE if the roll is a modifier, else otherwise.
      def modifier?(roll)
        roll.match(modifier_regex).nil?
      end
    end
  end
end

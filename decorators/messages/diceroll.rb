module Decorators
  module Messages
    class Diceroll < Draper::Decorator
      delegate_all

      def to_h
        return {
          id: object.id.to_s,
          type: 'diceroll',
          username: object.player.account.username,
          number_of_dices: object.number_of_dices,
          number_of_faces: object.number_of_faces,
          modifier: object.modifier,
          results: object.results,
          created_at: object.created_at.utc.iso8601
        }
      end
    end
  end
end
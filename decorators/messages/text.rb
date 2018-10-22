module Decorators
  module Messages
    class Text < Draper::Decorator
      delegate_all

      def to_h
        return {
          id: object.id.to_s,
          type: 'text',
          username: object.player.account.username,
          content: object.content,
          created_at: object.created_at.utc.iso8601
        }
      end
    end
  end
end
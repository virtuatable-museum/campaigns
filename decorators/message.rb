# frozen_string_literal: true

module Decorators
  # Decorator for an message object, providing vanity methods.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Message < Draper::Decorator
    delegate_all

    def to_h
      {
        id: object.id.to_s,
        username: object.player.account.username,
        type: object.type,
        created_at: object.created_at.utc.iso8601,
        data: object.data
      }
    end
  end
end

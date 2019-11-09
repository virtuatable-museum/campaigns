# frozen_string_literal: true

module Decorators
  # Decorator for an message object, providing vanity methods.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Message < Draper::Decorator
    delegate_all

    def to_h
      base = {
        id: object.id.to_s,
        username: object.player.account.username,
        created_at: object.created_at.utc.iso8601
      }

      base.merge(deleted ? { type: 'deleted' } : text_content)
    end

    def text_content
      {
        type: type,
        data: data
      }
    end
  end
end

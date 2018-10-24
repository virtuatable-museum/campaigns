module Decorators
  class Message < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id.to_s,
        username: object.player.account.username,
        type: object.type,
        created_at: object.created_at.utc.iso8601,
        data: object.data
      }
    end
  end
end
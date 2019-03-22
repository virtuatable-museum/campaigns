module Decorators
  class Invitation < Draper::Decorator
    delegate_all

    def to_simple_h(session = nil)
      return {
        id: object.id.to_s,
        status: object.status.to_s,
        created_at: object.created_at.utc.iso8601,
        username: object.account.username
      }
    end
  end
end
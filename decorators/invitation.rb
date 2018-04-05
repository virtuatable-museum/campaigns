module Decorators
  class Invitation < Draper::Decorator
    delegate_all

    def to_h
      return (if object.accepted
        {
          id: object.id.to_s,
          creator: object.creator.username,
          accepted_at: accepted_at.iso8601,
          username: object.account.username
        }
      else
        {
          id: object.id.to_s,
          creator: object.creator.username,
          username: object.account.username
        }
      end)
    end
  end
end
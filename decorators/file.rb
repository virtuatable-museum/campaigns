module Decorators
  class File < Draper::Decorator
    delegate_all

    def to_h
      account = object.invitation.account
      return {
        id: object.id.to_s,
        filename: object.filename,
        account: {
          id: account._id.to_s,
          username: account.username
        }
      }
    end
  end
end
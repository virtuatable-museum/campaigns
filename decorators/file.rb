module Decorators
  class File < Draper::Decorator
    delegate_all

    def to_h
      account = object.permissions.where(enum_level: :creator).first.invitation.account
      return {
        id: object.id.to_s,
        name: object.name,
        size: object.size,
        type: object.mime_type,
        account: {
          id: account._id.to_s,
          username: account.username
        }
      }
    end
  end
end
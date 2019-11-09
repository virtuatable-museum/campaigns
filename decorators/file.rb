# frozen_string_literal: true

module Decorators
  # Decorator for a file object, providing vanity methods.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class File < Draper::Decorator
    delegate_all

    def to_h
      {
        id: object.id.to_s,
        name: object.name,
        size: object.size,
        type: object.mime_type,
        account: account
      }
    end

    def account
      permission = object.permissions.where(enum_level: :creator).first
      acc = permission.invitation.account
      {
        id: acc._id.to_s,
        username: acc.username
      }
    end
  end
end

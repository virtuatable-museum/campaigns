# frozen_string_literal: true

module Decorators
  # Decorator for an invitation object, providing vanity methods.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Invitation < Draper::Decorator
    delegate_all

    def to_simple_h
      if hide?
        nil
      else
        {
          id: object.id.to_s,
          status: object.status.to_s,
          created_at: object.created_at.utc.iso8601,
          username: object.account.username
        }
      end
    end

    def hide?
      object.nil? || %i[left expelled refused].include?(enum_status)
    end
  end
end

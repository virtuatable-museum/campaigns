module Decorators
  class Campaign < Draper::Decorator
    delegate_all

    def to_h
      return {
        title: object.title,
        description: object.description,
        is_private: object.is_private,
        creator: {
          id: object.creator.id.to_s,
          username: object.creator.username
        }
      }
    end
  end
end
module Decorators
  class Campaign < Draper::Decorator
    delegate_all

    # Assign an array of tags to a campaign and refreshes or creates the associated counters.
    # @param tags [Array<String>] the tags to assign to the campaign in the current decorator.
    def assign_tags(tags)
      tags.each do |tag|
        tag_object = Arkaan::Campaigns::Tag.where(content: tag).first
        if tag_object.nil?
          Arkaan::Campaigns::Tag.create(content: tag)
        else
          tag_object.count = tag_object.count + 1
          tag_object.save
        end
      end
      object.update_attribute(:tags, tags)
    end

    def to_h
      return {
        id: _id.to_s,
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
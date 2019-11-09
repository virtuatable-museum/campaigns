# frozen_string_literal: true

module Decorators
  # Decorates a class model by adding it vanity methods.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Campaign < Draper::Decorator
    delegate_all

    # Assign an array of tags to a campaign and refreshes
    # or creates the associated counters.
    # @param tags [Array<String>] the tags to assign to the campaign
    #   in the current decorator.
    def assign_tags(tags)
      tags.each do |tag|
        tag_object = Arkaan::Campaigns::Tag.where(content: tag).first
        if tag_object.nil?
          Arkaan::Campaigns::Tag.create(content: tag, count: 1)
        else
          tag_object.count = tag_object.count + 1
          tag_object.save
        end
      end
      object.tags = tags
    end

    # Deletes all the tags for the campaign, and updates the associated
    # tags counters.
    def delete_tags
      object.tags.each do |tag|
        tag_object = Arkaan::Campaigns::Tag.where(content: tag).first
        if tag_object.count > 1
          tag_object.count = tag_object.count - 1
          tag_object.save
        else
          tag_object.delete
        end
      end
    end

    def players_count
      object.invitations.where(enum_status: :accepted).count
    end

    def waiting_count
      object.invitations.where(:enum_status.in => %i[pending request]).count
    end

    def to_creator_h
      to_h.merge(waiting_players: waiting_count)
    end

    def to_h
      {
        id: object._id.to_s,
        title: object.title,
        description: object.description,
        is_private: object.is_private,
        max_players: object.max_players,
        current_players: players_count,
        creator: creator,
        tags: object.tags
      }
    end

    def creator
      {
        id: object.creator.id.to_s,
        username: object.creator.username
      }
    end

    def with_invitations(session)
      invitation = object.invitations.where(account: session.account).first
      decorated = Decorators::Invitation.new(invitation)
      to_h.merge(invitation: decorated.to_simple_h)
    end
  end
end

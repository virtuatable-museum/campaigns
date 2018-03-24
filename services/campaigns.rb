require 'singleton'

module Services
  # The campaigns service wraps methods such as the creation of a campaign.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Campaigns
    include Singleton

    # Builds a new campaign with the given parameters and tags, updating the tags counters.
    # @param parameters [Hash] the parameters to build the campaign with.
    # @param tags [Array<String>] and array of string tags to identify the content of the campaign.
    def build(parameters, tags)
      campaign = Decorators::Campaign.new(Arkaan::Campaign.new(parameters))
      campaign.assign_tags(tags.uniq)
      return campaign
    end
  end
end
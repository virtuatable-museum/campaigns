# frozen_string_literal: true

module Services
  # Service to load the rulesets and their associated files.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rulesets
    include Singleton

    # @!attribute [rw] root
    #   @return [String] The root folder of the project, used to search for the "plugins"
    #     directory and correctly load all plugins.
    attr_accessor :root
    # @!attribute [rw] definitions
    #   @return [Array<Hash>] the definition of the plugin (filenames)
    attr_reader :definitions

    attr_reader :account

    def initialize
      @definitions = []
      @account = Arkaan::Account.where(username: 'Babausse').first
    end

    def load!
      Dir[File.join(root, 'plugins', '**')].each do |filename|
        load_directory!(filename) if File.directory? filename
      end
    end

    def load_directory!(directory)
      fullname = File.join(directory, 'plugin.json')
      definition = JSON.parse(File.open(fullname).read)
      existing = Arkaan::Ruleset.where(name: definition['name']).first
      create_ruleset(account, definition) if existing.nil?
      definition['folder'] = directory
      @definitions << definition
    end

    def create_ruleset(account, definition)
      Arkaan::Ruleset.create(
        name: definition['name'],
        description: definition['description'],
        creator: account
      )
    end

    def definition_for(campaign)
      return nil if campaign.ruleset.nil?

      definitions.find do |definition|
        definition['name'] == campaign.ruleset.name
      end
    end

    def self.load_from!(folder)
      instance.root = folder
      instance.load!
    end
  end
end

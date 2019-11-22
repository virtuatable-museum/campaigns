# frozen_string_literal: true

module Services
  # This service validates and creates characters in the database
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Characters
    include Singleton

    def create(invitation, data)
      character = Arkaan::Campaigns::Character.new(
        data: data,
        invitation: invitation,
        selected: true
      )
      character.save
      character
    end

    def rulesets
      Services::Rulesets.instance
    end

    def validate(invitation, data)
      definition = rulesets.definition_for(invitation.campaign)
      filename = File.join(definition['folder'], definition['validator'])
      validator = JSON.parse(File.open(filename).read)
      validator.all? do |field, constraints|
        send(:"validate_#{constraints['type']}", data[field], constraints)
      end
    end

    def validate_string(value, constraints)
      has_minlength = constraints.key?('minlength')
      return false if has_minlength && value.length < constraints['minlength']

      true
    end

    def validate_integer(value, constraints)
      return false unless value.is_a?(Integer) || !value.match(/^[0-9]+$/).nil?
      return false if constraints['min'] && value.to_i < constraints['min']

      true
    end

    def validate_enumeration(value, constraints)
      has_values = constraints.key?('values')
      return false if has_values && !constraints['values'].include?(value)

      true
    end
  end
end

module Services
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

    def validate(invitation, data)
      definition = Services::Rulesets.instance.definition_for(invitation.campaign)
      filename = File.join(definition['folder'], definition['validator'])
      validator = JSON.parse(File.open(filename).read)
      return validator.all? do |field, constraints|
        self.send(:"validate_#{constraints['type']}", data[field], constraints) rescue false
      end
    end

    def validate_string(value, constraints)
      if constraints['minlength'] && value.length < constraints['minlength']
        return false
      end
      return true
    end

    def validate_integer(value, constraints)
      return false unless value.is_a?(Integer) || !value.match(/^[0-9]+$/).nil?
      if constraints['min'] && value.to_i < constraints['min']
        return false
      end
      return true
    end

    def validate_enumeration(value, constraints)
      if constraints['values'] && !constraints['values'].include?(value)
        return false
      end
      return true
    end
  end
end
FactoryGirl.define do
  factory :empty_ruleset, class: Arkaan::Ruleset do
    factory :coddirole do
      name 'Coddirole'
      description 'Custom role playing system for Coddity'
    end
  end
end
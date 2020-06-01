FactoryBot.define do
  factory :empty_application, class: Arkaan::OAuth::Application do
    factory :application do
      name { Faker::Alphanumeric.unique.alphanumeric(number: 20) }
      key { Faker::Alphanumeric.unique.alphanumeric(number: 20) }
      premium { true }
    end
  end
end
FactoryGirl.define do
  factory :empty_campaign, class: Arkaan::Campaign do
    factory :campaign do
      title 'test_title'
      description 'A longer description of the campaign'
      is_private true
    end
  end
end
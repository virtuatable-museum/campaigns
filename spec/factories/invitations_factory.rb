FactoryGirl.define do
  factory :empty_invitation, class: Arkaan::Campaigns::Invitation do
    factory :invitation do
      factory :accepted_invitation do
        accepted true
      end
      factory :pending_invitation do
        accepted false
      end
    end
  end
end
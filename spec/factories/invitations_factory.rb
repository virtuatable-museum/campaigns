FactoryGirl.define do
  factory :empty_invitation, class: Arkaan::Campaigns::Invitation do
    factory :invitation do
      factory :accepted_invitation do
        status :accepted
      end
      factory :pending_invitation do
        status :pending
      end
    end
  end
end
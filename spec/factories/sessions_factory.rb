FactoryGirl.define do
  factory :empty_session, class: Arkaan::Authentication::Session do
    factory :session do
      token 'super_long_token'
    end
    factory :another_session do
      token 'any_other_long_token'
    end
  end
end
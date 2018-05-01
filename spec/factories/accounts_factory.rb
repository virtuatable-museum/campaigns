FactoryGirl.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      username 'Babausse'
      password 'password'
      password_confirmation 'password'
      email 'machin@test.com'
      lastname 'Courtois'
      firstname 'Vincent'

      factory :another_account do
        username 'Another'
        email 'another@maail.com'
      end
    end
  end
end
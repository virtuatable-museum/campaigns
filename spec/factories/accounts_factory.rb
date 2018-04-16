FactoryGirl.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      username 'Babausse'
      password 'password'
      password_confirmation 'password'
      email 'machin@test.com'
      lastname 'Courtois'
      firstname 'Vincent'
      birthdate DateTime.new(1989, 8, 29, 21, 50)

      factory :another_account do
        username 'Another'
        email 'another@maail.com'
      end
    end
  end
end
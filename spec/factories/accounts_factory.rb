FactoryGirl.define do
  factory :empty_account, class: Arkaan::Account do
    factory :account do
      username { Faker::Internet.unique.username(5..10) }
      password 'password'
      password_confirmation 'password'
      email { Faker::Internet.unique.safe_email }
      lastname { Faker::Name.last_name }
      firstname { Faker::Name.first_name }
    end

    factory :didier do
      username 'Didier l\'épervier'
      password 'password'
      password_confirmation 'password'
      email 'didier@test.com'
      lastname 'Super'
      firstname 'Didier'
    end

    factory :jacques do
      username 'Jacques la matraque'
      password 'password'
      password_confirmation 'password'
      email 'jacques@test.com'
      lastname 'Chirac'
      firstname 'Jacques'
    end

    factory :louis do
      username 'Louis l\'étourdi'
      password 'password'
      password_confirmation 'password'
      email 'louis@test.com'
      lastname 'Quatorze'
      firstname 'Louis'
    end
  end
end
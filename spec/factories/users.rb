FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Name.name[0..14] }
    password { SecureRandom.hex(5) }
  end
end

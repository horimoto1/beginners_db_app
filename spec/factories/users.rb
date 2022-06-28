FactoryBot.define do
  factory :user do
    name { 'foobar' }
    email { 'foobar@example.com' }
    password { 'foobar' }
    admin { true }
  end
end

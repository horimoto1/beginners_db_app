# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  admin               :boolean          default(FALSE)
#  email               :string           default(""), not null
#  encrypted_password  :string           default(""), not null
#  name                :string           not null
#  remember_created_at :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    name { "foobar" }
    email { "foobar@example.com" }
    password { "foobar" }
    admin { true }
  end
end

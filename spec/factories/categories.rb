# == Schema Information
#
# Table name: categories
#
#  id                 :integer          not null, primary key
#  category_order     :integer          not null
#  name               :string           not null
#  slug               :string           default(""), not null
#  summary            :text
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_category_id :integer
#
# Indexes
#
#  index_categories_on_name   (name) UNIQUE
#  index_categories_on_slug   (slug) UNIQUE
#  index_categories_on_title  (title) UNIQUE
#
# Foreign Keys
#
#  parent_category_id  (parent_category_id => categories.id)
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "test#{n}" }
    sequence(:title) { |n| "タイトル#{n}" }
    summary { "テストカテゴリー" }
    sequence(:category_order) { |n| n }
    parent_category_id { nil }
  end
end

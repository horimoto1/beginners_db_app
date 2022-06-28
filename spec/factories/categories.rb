FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "test#{n}" }
    sequence(:title) { |n| "タイトル#{n}" }
    summary { "テストカテゴリー" }
    sequence(:category_order) { |n| n }
    parent_category_id { nil }
  end
end

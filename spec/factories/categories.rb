FactoryBot.define do
  factory :category do
    name { Faker::Internet.slug }
    title { Faker::Lorem.sentence(word_count: 3) }
    summary { Faker::Lorem.paragraph(sentence_count: 3) }
    category_order { 1 }
    parent_category_id { nil }
  end
end

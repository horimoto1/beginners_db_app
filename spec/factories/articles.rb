FactoryBot.define do
  factory :article do
    transient do
      published { false }
    end

    name { Faker::Internet.slug }
    title { Faker::Lorem.sentence(word_count: 3) }
    summary { Faker::Lorem.paragraph(sentence_count: 3) }
    content { Faker::Markdown.random }
    article_order { 1 }
    status { published ? "published" : "private" }
    association :category
  end
end

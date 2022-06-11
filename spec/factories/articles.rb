FactoryBot.define do
  factory :article do
    transient do
      published { false }
    end

    sequence(:name) { |n| "test#{n}" }
    sequence(:title) { |n| "タイトル#{n}" }
    summary { "テスト記事" }
    content { "# テスト" }
    sequence(:article_order) { |n| n }
    status { published ? "published" : "private" }
    association :category
  end
end

# == Schema Information
#
# Table name: articles
#
#  id            :integer          not null, primary key
#  article_order :integer          not null
#  content       :text             not null
#  name          :string           not null
#  slug          :string           default(""), not null
#  status        :string           not null
#  summary       :text
#  title         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_id   :integer          not null
#
# Indexes
#
#  index_articles_on_category_id                    (category_id)
#  index_articles_on_category_id_and_article_order  (category_id,article_order)
#  index_articles_on_name                           (name) UNIQUE
#  index_articles_on_slug                           (slug) UNIQUE
#  index_articles_on_title                          (title) UNIQUE
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#
FactoryBot.define do
  factory :article do
    transient do
      published { false }
    end

    sequence(:name) { |n| "test#{n}" }
    sequence(:title) { |n| "タイトル#{n}" }
    summary { "テスト記事" }
    content { "# テスト1\n## テスト2\n### テスト3" }
    sequence(:article_order) { |n| n }
    status { published ? "published" : "private" }
    association :category
  end
end

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
class Article < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category, optional: true # 関連先を検査しないようにする

  PUBLISHED_STATUS = "published".freeze

  scope :sorted, -> { order(article_order: :asc, id: :asc) }
  scope :published, -> { where(status: PUBLISHED_STATUS) }
  scope :with_category, -> { includes(:category) }

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true
  validates :article_order, presence: true
  validates :status, presence: true
  validates :category_id, presence: true

  validate :category_id_should_be_exists

  # 前の記事を取得する
  def previous_article
    sql = <<~SQL
      SELECT
        t1.*
      FROM
        articles t1
        INNER JOIN (
          SELECT
            id,
            LAG(id, 1) OVER(PARTITION BY category_id
              ORDER BY article_order ASC, id ASC) AS previous_article_id
          FROM
            articles
        ) t2
        ON
          t1.id = t2.previous_article_id
      WHERE
        t2.id = #{id}
      LIMIT 1
    SQL

    Article.find_by_sql(sql).first
  end

  # 次の記事を取得する
  def next_article
    sql = <<~SQL
      SELECT
        t1.*
      FROM
        articles t1
        INNER JOIN (
          SELECT
            id,
            LEAD(id, 1) OVER(PARTITION BY category_id
              ORDER BY article_order ASC, id ASC) AS next_article_id
          FROM
            articles
        ) t2
        ON
          t1.id = t2.next_article_id
      WHERE
        t2.id = #{id}
      LIMIT 1
    SQL

    Article.find_by_sql(sql).first
  end

  def published?
    status == PUBLISHED_STATUS
  end

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  # カテゴリーIDが存在するかバリデーションする
  def category_id_should_be_exists
    unless Category.exists?(category_id)
      errors.add(:category_id, "が存在しません")
    end
  end
end

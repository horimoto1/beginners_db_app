class Article < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category, optional: true # 関連先を検査しないようにする

  PUBLISHED_STATUS = "published"

  scope :sorted, -> { order(article_order: :asc, id: :asc) }
  scope :published, -> { where(status: PUBLISHED_STATUS) }

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true
  validates :article_order, presence: true
  validates :status, presence: true
  validates :category_id, presence: true

  validate :category_id_should_be_exists

  # 前の記事を取得する
  def previous_article
    sql = <<~EOS
      SELECT *
        FROM articles
        WHERE id = 
          (SELECT previous_article_id
            FROM
              (SELECT id,
                LAG(id ,1) OVER (PARTITION BY category_id
                  ORDER BY article_order ASC, id ASC) AS previous_article_id
                FROM articles
              )
            WHERE id = #{self.id}
            LIMIT 1
          )
    EOS

    Article.find_by_sql(sql).first
  end

  # 次の記事を取得する
  def next_article
    sql = <<~EOS
      SELECT *
        FROM articles
        WHERE id =
          (SELECT next_article_id
            FROM
              (SELECT id,
                LEAD(id ,1) OVER (PARTITION BY category_id
                  ORDER BY article_order ASC, id ASC) AS next_article_id
                FROM articles
              )
            WHERE id = #{self.id}
            LIMIT 1
          )
    EOS

    Article.find_by_sql(sql).first
  end

  def published?
    self.status == PUBLISHED_STATUS
  end

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  # カテゴリーIDが存在するかバリデーションする
  def category_id_should_be_exists
    unless Category.exists?(self.category_id)
      errors.add(:category_id, "が存在しません")
    end
  end
end

class Article < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category

  default_scope -> { order(article_order: :asc, id: :asc) }

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :content, presence: true
  validates :article_order, presence: true
  validates :status, presence: true
  validates :category_id, presence: true

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

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end
end

class Category < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  has_many :child_categories, class_name: "Category",
                              foreign_key: "parent_category_id",
                              dependent: :destroy
  belongs_to :parent_category, class_name: "Category",
                               foreign_key: "parent_category_id",
                               optional: true
  has_many :articles, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :category_order, presence: true

  # 前のカテゴリーを取得する
  def previous_category
    sql = <<~EOS
      SELECT *
        FROM categories
        WHERE id = 
          (SELECT previous_category_id
            FROM
              (SELECT id,
                LAG(id ,1) OVER (PARTITION BY parent_category_id
                  ORDER BY category_order ASC, id ASC) AS previous_category_id
                FROM categories
              )
            WHERE id = #{self.id}
            LIMIT 1
          )
    EOS

    Category.find_by_sql(sql).first
  end

  # 次のカテゴリーを取得する
  def next_category
    sql = <<~EOS
      SELECT *
        FROM categories
        WHERE id =
          (SELECT next_category_id
            FROM
              (SELECT id,
                LEAD(id ,1) OVER (PARTITION BY parent_category_id
                  ORDER BY category_order ASC, id ASC) AS next_category_id
                FROM categories
              )
            WHERE id = #{self.id}
            LIMIT 1
          )
    EOS

    Category.find_by_sql(sql).first
  end

  # パンくずリストを取得する
  def breadcrumb_list
    sql = <<~EOS
      WITH RECURSIVE tmp AS (
        SELECT *
          FROM categories
          WHERE id = #{self.id}
        UNION ALL
        SELECT categories.*
          FROM tmp, categories
          WHERE tmp.parent_category_id = categories.id
      )
      SELECT *
        FROM tmp
    EOS

    Category.find_by_sql(sql).reverse
  end

  # ルートカテゴリー一覧を取得する
  def self.root_categories
    Category.where(parent_category_id: nil)
      .order(category_order: :asc, id: :asc)
  end

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end
end

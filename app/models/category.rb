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
class Category < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  has_many :child_categories,
           class_name: "Category",
           foreign_key: "parent_category_id",
           dependent: :destroy,
           inverse_of: :parent_category
  belongs_to :parent_category,
             class_name: "Category",
             optional: true,
             inverse_of: :child_categories
  has_many :articles,
           dependent: :destroy

  scope :sorted, -> { order(category_order: :asc, id: :asc) }
  scope :root_categories, -> { where(parent_category_id: nil) }
  scope :with_articles, -> { eager_load(:articles) }

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :category_order, presence: true

  validate :parent_category_id_should_be_null_or_exists

  # 前のカテゴリーを取得する
  def previous_category
    sql = <<~SQL
      WITH previous_category_tbl AS(
        SELECT
          id,
          LAG(id, 1) OVER(PARTITION BY parent_category_id
            ORDER BY category_order ASC, id ASC) AS previous_category_id
        FROM
          categories
      )

      SELECT
        *
      FROM
        categories
      WHERE
        id = (SELECT previous_category_id FROM previous_category_tbl
          WHERE id = #{id} LIMIT 1)
    SQL

    Category.find_by_sql(sql).first
  end

  # 次のカテゴリーを取得する
  def next_category
    sql = <<~SQL
      WITH next_category_tbl AS(
        SELECT
          id,
          LEAD(id, 1) OVER(PARTITION BY parent_category_id
            ORDER BY category_order ASC, id ASC) AS next_category_id
        FROM
          categories
      )

      SELECT
        *
      FROM
        categories
      WHERE
        id = (SELECT next_category_id FROM next_category_tbl
          WHERE id = #{id} LIMIT 1)
    SQL

    Category.find_by_sql(sql).first
  end

  # 祖先Categoryを全て含むツリーを取得する
  def category_tree
    sql = <<~SQL
      WITH RECURSIVE tmp AS(
        SELECT
          *
        FROM
          categories
        WHERE
          id = #{id}
        UNION ALL
        SELECT
          categories.*
        FROM
          tmp,
          categories
        WHERE
          tmp.parent_category_id = categories.id
      )

      SELECT
        *
      FROM
        tmp
    SQL

    Category.find_by_sql(sql).reverse
  end

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end

  # 親カテゴリーIDがnullまたは存在するかバリデーションする
  def parent_category_id_should_be_null_or_exists
    return if parent_category_id.nil?

    unless Category.exists?(parent_category_id)
      errors.add(:parent_category_id, "がnullではないか存在しません")
    end
  end
end

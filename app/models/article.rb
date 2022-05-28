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

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end
end

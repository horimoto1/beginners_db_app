class Category < ApplicationRecord
  # スラッグ
  include FriendlyId
  friendly_id :name, use: :slugged

  has_many :articles, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :category_order, presence: true

  private

  # nameが更新された際に、slugも自動で更新されるようにする
  def should_generate_new_friendly_id?
    name_changed? || super
  end
end

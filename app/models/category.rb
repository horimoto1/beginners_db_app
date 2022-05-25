class Category < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true
  validates :category_order, presence: true
end

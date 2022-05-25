class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :title, presence: true
  validates :category_order, presence: true
end

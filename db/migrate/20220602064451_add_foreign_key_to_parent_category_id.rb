class AddForeignKeyToParentCategoryId < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :categories, :categories, column: :parent_category_id
  end
end

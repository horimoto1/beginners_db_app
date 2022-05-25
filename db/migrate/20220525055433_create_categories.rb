class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :title
      t.integer :category_order
      t.integer :parent_category_id

      t.timestamps
    end
  end
end

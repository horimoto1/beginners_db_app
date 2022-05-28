class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.text :summary
      t.integer :category_order, null: false
      t.integer :parent_category_id

      t.timestamps
    end
  end
end

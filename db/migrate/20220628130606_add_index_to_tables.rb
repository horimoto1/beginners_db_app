class AddIndexToTables < ActiveRecord::Migration[6.0]
  def change
    add_index :categories, :name, unique: true
    add_index :categories, :title, unique: true

    add_index :articles, :name, unique: true
    add_index :articles, :title, unique: true
  end
end

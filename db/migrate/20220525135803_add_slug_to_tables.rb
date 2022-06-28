class AddSlugToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :slug, :string, null: false, default: ''
    add_index :categories, :slug, unique: true

    add_column :articles, :slug, :string, null: false, default: ''
    add_index :articles, :slug, unique: true
  end
end

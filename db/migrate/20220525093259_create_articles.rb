class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :article_order, null: false
      t.string :status, null: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :articles, [:category_id, :article_order]
  end
end

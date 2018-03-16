class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.string :description
      t.string :slug
      t.integer :favorites_count
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :articles, :slug, unique: true
  end
end

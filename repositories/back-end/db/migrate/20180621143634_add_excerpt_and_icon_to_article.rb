class AddExcerptAndIconToArticle < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :icon, :string
    add_column :articles, :excerpt, :string
  end
end

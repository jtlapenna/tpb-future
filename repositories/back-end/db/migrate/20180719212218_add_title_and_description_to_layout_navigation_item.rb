class AddTitleAndDescriptionToLayoutNavigationItem < ActiveRecord::Migration[5.1]
  def change
    add_column :layout_navigation_items, :title, :string
    add_column :layout_navigation_items, :description, :string
  end
end

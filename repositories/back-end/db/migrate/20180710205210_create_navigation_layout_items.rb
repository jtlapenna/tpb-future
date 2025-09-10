class CreateNavigationLayoutItems < ActiveRecord::Migration[5.1]
  def change
    create_table :layout_navigation_items do |t|
      t.string :label
      t.string :link
      t.integer :order, default: 0
      t.belongs_to :layout_navigation, foreign_key: true

      t.timestamps
    end
  end
end

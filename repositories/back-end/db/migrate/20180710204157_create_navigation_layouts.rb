class CreateNavigationLayouts < ActiveRecord::Migration[5.1]
  def change
    create_table :layout_navigations do |t|
      t.belongs_to :store_layout, foreign_key: true

      t.timestamps
    end
  end
end

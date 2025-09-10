class CreateGreenDots < ActiveRecord::Migration[5.1]
  def change
    create_table :green_dots do |t|
      t.string :cord_x
      t.string :cord_y
      t.string :link

      t.integer :store_asset_id

      t.timestamps
    end
  end
end

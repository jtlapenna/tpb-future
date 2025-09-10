class CreateLayoutPositions < ActiveRecord::Migration[5.1]
  def up
    create_table :layout_positions do |t|
      t.string :label

      t.timestamps
    end

    positions = %w(top-left top-center top-right left-center center rigth-center bottom-left bottom-center bottom-right fullscreen)
    positions.each do |position|
      LayoutPosition.create label: position
    end
  end
  def down
    drop_table :layout_positions
  end
end

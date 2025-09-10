class AddDataToKiosk < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosks, :data, :text
  end
end

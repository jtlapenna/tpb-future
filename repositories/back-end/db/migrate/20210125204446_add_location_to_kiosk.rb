class AddLocationToKiosk < ActiveRecord::Migration[6.0]
  def change
    add_column :kiosks, :location, :string, null: true
  end
end

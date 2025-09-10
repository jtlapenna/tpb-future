class CreateCarts < ActiveRecord::Migration[6.0]
  def change
    create_table :carts do |t|
      t.boolean :is_active
      t.string :phone_number
      t.datetime :checkout_date

      t.timestamps
    end
  end
end

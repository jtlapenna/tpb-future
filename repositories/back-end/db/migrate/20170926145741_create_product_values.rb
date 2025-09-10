class CreateProductValues < ActiveRecord::Migration[5.1]
  def change
    create_table :product_values do |t|
      t.string :name
      t.decimal :value, precision: 10, scale: 2
      t.references :valuable, polymorphic: true

      t.timestamps
    end
  end
end

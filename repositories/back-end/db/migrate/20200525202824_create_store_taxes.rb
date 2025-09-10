class CreateStoreTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :store_taxes do |t|
      t.string :name
      t.float :value
      t.belongs_to :store
    end
  end
end

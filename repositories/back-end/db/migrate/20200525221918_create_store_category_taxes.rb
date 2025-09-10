class CreateStoreCategoryTaxes < ActiveRecord::Migration[6.0]
  def change
    create_table :store_category_taxes do |t|
      t.string :name
      t.float :value
      t.belongs_to :store_category
    end
  end
end

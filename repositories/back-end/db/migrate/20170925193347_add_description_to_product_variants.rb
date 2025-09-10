class AddDescriptionToProductVariants < ActiveRecord::Migration[5.1]
  def change
    add_column :product_variants, :description, :string
  end
end

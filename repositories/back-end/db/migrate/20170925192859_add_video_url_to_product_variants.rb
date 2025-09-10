class AddVideoUrlToProductVariants < ActiveRecord::Migration[5.1]
  def change
    add_column :product_variants, :video_url, :string
  end
end

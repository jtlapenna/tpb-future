class CreateJoinTableProductVariantImage < ActiveRecord::Migration[5.1]
  def change
    create_join_table :product_variants, :images do |t|
      t.index [:product_variant_id, :image_id], name: 'variant_images_join_table'
      t.index [:image_id, :product_variant_id], name: 'images_variant_join_table'
    end
  end
end

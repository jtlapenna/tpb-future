class AddOverrideTagsToProductVariant < ActiveRecord::Migration[5.1]
  def change
    add_column :product_variants, :override_tags, :boolean, default: false
  end
end

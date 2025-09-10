class StoreProductWithValuesSerializer < ActiveModel::Serializer
  attributes :id, :sku, :name, :weight, :tag_list, :description, :share_email_template, :share_sms_template,
             :stock, :override_tags, :status, :latest_update_source

  belongs_to :product_variant, serializer: ProductVariantSerializer
  belongs_to :store_category
end

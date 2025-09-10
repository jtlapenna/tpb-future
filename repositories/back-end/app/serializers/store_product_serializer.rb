class StoreProductSerializer < ActiveModel::Serializer
  attributes :id, :sku, :name, :weight, :tag_list, :description, :share_email_template, :share_sms_template,
             :stock, :override_tags, :status, :latest_update_source, :is_medical_only , :is_full_screen

  belongs_to :product_variant
  belongs_to :brand
  belongs_to :store_category
  belongs_to :primary_image
  belongs_to :thumb_image
  has_one :store, serializer: StoreMinimalSerializer

  has_many :product_values
  has_many :images
  has_many :own_images
  has_many :attribute_values

  has_one :video

  def store_taxes
    store_taxes = []

    object.store.store_taxes.each do |store_tax|
      store_taxes.push(store_tax)
    end

    return store_taxes
  end
end

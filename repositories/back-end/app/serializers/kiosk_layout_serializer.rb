class KioskLayoutSerializer < ActiveModel::Serializer
  attributes :id, :template, :disable_overlay_mask, :home_layout, :nav_ui, :product_layout_id, :stand_side, :rfid_disabled,
             :welcome_message, :shopping_disabled, :screen_type,
             :store_category_id, :on_sale_badges, :checkout_text, :pagination_time, :home_screen_title, :fast_animation, :store_categories

  belongs_to :kiosk, serializer: KioskMinimalSerializer
  belongs_to :welcome_asset
  belongs_to :video_image_background_asset
  belongs_to :store_category
  has_many :store_category_kiosk_layouts
  has_many :store_categories do
    @object.store_categories.map { |sc|
      {
        id: sc[:id],
        name: sc[:name],
        order: @object.store_category_kiosk_layouts.select{|sckl| sckl.store_category_id == sc.id}[0][:order],
        store_id: sc[:store_id]
      }
    }
  end

  has_one :navigation

  has_many :kiosk_assets
end

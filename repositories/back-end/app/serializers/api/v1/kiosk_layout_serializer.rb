module Api
  module V1
    class KioskLayoutSerializer < ActiveModel::Serializer
      attributes :id, :template, :home_layout, :nav_ui, :stand_side, :rfid_disabled,
                 :shopping_disabled, :welcome_message, :screen_type, :created_at, :updated_at,
                 :store_category_id, :on_sale_badges, :checkout_text, :pagination_time, :home_screen_title, :disable_overlay_mask, :fast_animation, :store_categories

      # belongs_to :store, serializer: Api::V1::StoreSerializer
      belongs_to :welcome_asset, serializer: Api::V1::WelcomeAssetSerializer
      belongs_to :video_image_background_asset, serializer: Api::V1::VideoImageBackgroundAssetSerializer
      belongs_to :store_category, serializer: Api::V1::StoreCategorySerializer
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

      has_one :navigation, serializer: Api::V1::LayoutNavigationSerializer

      has_many :kiosk_assets,
               key: :store_assets,
               include: [
                 'pictures_in_pictures.asset',
                 'dots.asset',
                 'asset'
               ],
               serializer: Api::V1::KioskAssetSerializer
    end
  end
end

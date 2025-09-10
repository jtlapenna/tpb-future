class KioskLayoutPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :template, :home_layout, :nav_ui, :product_layout_id, :stand_side,
      :store_id, :welcome_message, :rfid_disabled, :shopping_disabled,
      :screen_type, :store_category_id, :on_sale_badges, :checkout_text, :pagination_time, :home_screen_title, :fast_animation, :store_categories, :disable_overlay_mask,
      kiosk_assets_attributes: [
        :id, :asset_position_id, :text_position_id, :section_position_id,
        :text, :secondary_text, :code, :_destroy,
        asset_attributes: %i[id url _destroy],
        asset_elements_attributes: [
          :id, :coord_x, :coord_y, :link, :element_type, :_destroy,
          asset_attributes: %i[id url _destroy]
        ]
      ],
      navigation_attributes: [
        :id, :_destroy,
        items_attributes: [
          :id, :label, :link, :title, :description, :order, :_destroy,
          asset_attributes: %i[id url _destroy]
        ]
      ],
      welcome_asset_attributes: [
        :id, :asset_position_id, :_destroy,
        asset_attributes: %i[id url _destroy]
      ],
      video_image_background_asset_attributes: [
        :id, :asset_position_id, :_destroy,
        asset_attributes: %i[id url _destroy]
      ]
    ]
  end
end

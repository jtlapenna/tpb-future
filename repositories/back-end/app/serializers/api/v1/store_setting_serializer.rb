module Api
  module V1
    class StoreSettingSerializer < ActiveModel::Serializer
      attributes :admin_email, :printer_location, :pos_location, :main_color, :secondary_color,
                 :featured_products_on_top_for_brands_page,
                 :featured_products_on_top_for_effects_and_uses_page,
                 :featured_products_on_top_for_products_page, :idle_delay, :restart_delay,
                 :service_worker_log, :default_product_description, :heap_id,
                 :dispensary_license_number, :lat, :lng, :t_a_c, :global_ad_enabled, :show_thc_cbd_values, :disable_tax_message, :rfid_popup_setting, :enable_request_tax, :show_alternative_flower_icon, :use_master_category, :checkout_message, :printer_mac_address, :enable_toggle_tax, :default_toggle_customer_type

      has_one :background_media
    end
  end
end

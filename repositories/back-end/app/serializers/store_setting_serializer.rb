class StoreSettingSerializer < ActiveModel::Serializer
  attributes :id, :printer_location, :main_color, :secondary_color,
             :featured_products_on_top_for_brands_page,
             :featured_products_on_top_for_effects_and_uses_page,
             :featured_products_on_top_for_products_page,
             :default_product_description, :dispensary_license_number, 
             :lat, :lng, :t_a_c, :global_ad_enabled, :show_thc_cbd_values, :disable_tax_message, :rfid_popup_setting, :enable_request_tax, :show_alternative_flower_icon, :use_master_category, :printer_mac_address, :enable_toggle_tax, :default_toggle_customer_type

  attribute :admin_email, if: -> { scope && scope.admin? }
  attribute :pos_location, if: -> { scope && scope.admin? }
  attribute :idle_delay, if: -> { scope && scope.admin? }
  attribute :restart_delay, if: -> { scope && scope.admin? }
  attribute :service_worker_log, if: -> { scope && scope.admin? }
  attribute :heap_id, if: -> { scope && scope.admin? }
  attribute :checkout_message, if: -> { scope && scope.admin? }
  attribute :printer_mac_address, if: -> { scope && scope.admin? }

  has_one :background_media

  has_many :purchase_limits
end

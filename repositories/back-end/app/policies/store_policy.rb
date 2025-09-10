class StorePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.owner(user)
      end
    end
  end

  def index?
    user
  end

  def show?
    user
  end

  def update?
    user
  end

  def generate_token?
    admin?
  end

  def tax_customer_types?
    admin?
  end

  def get_inventory_types?
    admin?
  end

  def permitted_attributes
    attrs = [
      :name,
      :enabled_share_email_product, :enabled_continuous_cart, :enabled_share_sms_product, :block_simultaneous_nfc,
      :notifications_title, :notifications_enabled, :notifications_intro,
      :notifications_send_to_customer,
      { notifications_recipients: [] },
      logo_attributes: %i[id url _destroy],
    ]

    admin_attr = %i[
      client_id
      api_client_id api_key api_type dispensary_name sync_frequency sync_frequency_offset
      api_version api_store_id api_automatch api_autopublish
      override_on_sync preserve_category featured_mode sync_tags location_id
      auth0_client_id auth0_client_secret customer_type_filter checkout_type direct_checkout shop_url password
      grant_type client_cova_id client_cova_secret username password_cova company_id location_id_covasoft use_master_category use_total_thc authorization_blaze enable_automate_promotions
      partner_key_blaze inventory_list
    ]

    (
      user.admin? ? attrs + admin_attr : attrs
    ) + [{ settings_attributes: permitted_settings_attributes }]
  end

  protected

  def permitted_settings_attributes
    attrs = [
      :id, :printer_location, :main_color, :secondary_color,
      :featured_products_on_top_for_brands_page,
      :featured_products_on_top_for_effects_and_uses_page,
      :featured_products_on_top_for_products_page, :default_product_description,
      :dispensary_license_number, :lat, :lng, :global_ad_enabled, :show_thc_cbd_values, :show_alternative_flower_icon, :t_a_c, :disable_tax_message, :rfid_popup_setting, :enable_request_tax, :use_master_category, :printer_mac_address, :enable_toggle_tax, :default_toggle_customer_type, :enable_automate_promotions,
      purchase_limits_attributes: [:id, :limit, :name, :_destroy, store_category_ids: []],
      background_media_attributes: %i[id url _destroy]
    ]

    admin_attr = %i[
      admin_email pos_location idle_delay restart_delay service_worker_log heap_id checkout_message
    ]

    user.admin? ? attrs + admin_attr : attrs
  end
end

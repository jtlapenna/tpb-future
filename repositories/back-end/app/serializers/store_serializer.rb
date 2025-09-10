class StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :current_sync_id, :featured_mode, :enabled_share_email_product, :block_simultaneous_nfc,
             :enabled_share_sms_product, :enabled_continuous_cart

  has_one :logo
  belongs_to :client
  has_one :settings
  has_many :store_taxes

  # Api Integration
  attribute :api_type, if: -> { scope && scope.admin? }
  attribute :api_client_id, if: -> { scope && scope.admin? }
  attribute :api_key, if: -> { scope && scope.admin? }
  attribute :dispensary_name, if: -> { scope && scope.admin? }
  attribute :sync_frequency, if: -> { scope && scope.admin? }
  attribute :sync_frequency_offset, if: -> { scope && scope.admin? }
  attribute :api_version, if: -> { scope && scope.admin? }
  attribute :api_automatch, if: -> { scope && scope.admin? }
  attribute :override_on_sync, if: -> { scope && scope.admin? }
  attribute :preserve_category, if: -> { scope && scope.admin? }
  attribute :api_store_id, if: -> { scope && scope.admin? }
  attribute :api_autopublish, if: -> { scope && scope.admin? }
  attribute :sync_tags, if: -> { scope && scope.admin? }
  attribute :location_id, if: -> { scope && scope.admin? }
  attribute :auth0_client_id, if: -> { scope && scope.admin? }
  attribute :auth0_client_secret, if: -> { scope && scope.admin? }
  attribute :customer_type_filter, if: -> { scope && scope.admin? }
  attribute :webhook_url, if: -> { scope && scope.admin? }
  attribute :checkout_type, if: -> { scope && scope.admin? }
  attribute :direct_checkout, if: -> { scope && scope.admin? }
  attribute :shop_url, if: -> { scope && scope.admin? }
  attribute :password, if: -> { scope && scope.admin? }
  attribute :grant_type, if: -> { scope && scope.admin? }
  attribute :client_cova_id, if: -> { scope && scope.admin? }
  attribute :client_cova_secret, if: -> { scope && scope.admin? }
  attribute :username, if: -> { scope && scope.admin? }
  attribute :password_cova, if: -> { scope && scope.admin? }
  attribute :company_id, if: -> { scope && scope.admin? }
  attribute :location_id_covasoft, if: -> { scope && scope.admin? }
  attribute :use_master_category, if: -> { scope && scope.admin? }
  attribute :use_total_thc, if: -> { scope && scope.admin? }
  attribute :enable_automate_promotions, if: -> { scope && scope.admin? }
  attribute :authorization_blaze, if: -> {scope && scope.admin? }
  attribute :partner_key_blaze, if: -> {scope && scope.admin?}
  attribute :inventory_list, if: -> {scope && scope.admin?}

  # Notification settings
  attribute :notifications_title
  attribute :notifications_recipients
  attribute :notifications_enabled
  attribute :notifications_intro
  attribute :notifications_send_to_customer

  has_many :store_categories
  # do
  #   object.store_categories.sort { |cc1, cc2| cc1.name.downcase <=> cc2.name.downcase }
  # end

  def current_sync_id
    object.current_sync.id if object.current_sync && !object.current_sync.finished?
  end
end

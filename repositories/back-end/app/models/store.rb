class Store < ApplicationRecord
  enum featured_mode: { rfid_featured: 0, manual_featured: 1, rfid_and_manual_featured: 2 }

  belongs_to :client, inverse_of: :stores, optional: true

  has_many :kiosks, dependent: :nullify

  has_many :store_categories, dependent: :nullify
  has_many :store_products, through: :store_categories
  has_many :product_variants, through: :store_products
  has_many :duplicated_sku_deleted_logs, dependent: :nullify
  has_many :expired_kiosk_products, dependent: :nullify

  has_many :store_articles, dependent: :nullify

  has_many :store_syncs, dependent: :nullify

  has_many :store_prices, dependent: :nullify
  has_many :ad_banners, dependent: :nullify
  has_many :payment_gateways, dependent: :nullify

  has_many :store_taxes, dependent: :nullify

  has_one :logo, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :logo, allow_destroy: true, reject_if: :all_blank

  has_one :settings, class_name: 'StoreSetting', dependent: :nullify
  accepts_nested_attributes_for :settings, reject_if: :all_blank
  has_many :store_product_promotions, through: :store_products

  has_many :customers
  has_many :customer_orders

  store :api_settings, accessors: %i[
    api_type dispensary_name sync_frequency sync_frequency_offset api_client_id
    api_key api_version api_store_id api_automatch api_autopublish override_on_sync preserve_category sync_tags
    location_id auth0_client_id auth0_client_secret customer_type_filter checkout_type direct_checkout shop_url password
    grant_type client_cova_id client_cova_secret username password_cova company_id location_id_covasoft use_master_category use_total_thc enable_automate_promotions
    authorization_blaze partner_key_blaze inventory_list
  ], coder: JSON

  store :notification_settings, accessors: %i[
    notifications_recipients notifications_enabled notifications_title
    notifications_intro notifications_send_to_customer
  ], coder: JSON

  validates :name, presence: true, uniqueness: { scope: :client_id }

  validates :api_type, inclusion: { in: %w[treez headset flowhub leaflogix shopify covasoft blaze] }, allow_nil: true

  validates :sync_frequency,
            presence: true,
            numericality: { greater_than: 0, allow_blank: true },
            if: :api_type
  validates :sync_frequency_offset,
            numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_blank: true },
            if: :api_type
  
  validates :dispensary_name, :api_key, presence: true, if: :api_type_treez?
  validates :grant_type, :client_cova_id, :client_cova_secret, :username, :password_cova, :company_id, :location_id_covasoft, presence: true, if: :api_type_covasoft?
  validates :authorization_blaze, :partner_key_blaze, presence:true, if: :api_type_blaze?
  validates :api_store_id, :api_key, presence: true, if: :api_type_headset?
  validates :location_id, :api_key, :auth0_client_id, :auth0_client_secret,
            presence: true,
            if: :api_type_flowhub?
  validates :customer_type_filter,
            inclusion: { in: %w[recCustomer medCustomer] },
            allow_nil: true,
            if: :api_type_flowhub?
  validates :api_key, presence: true, if: :api_type_leaflogix?
  validates :notifications_recipients, :notifications_title, :notifications_intro,
            presence: true, if: :notifications_enabled
  validates :checkout_type, inclusion: { in: %w[phone email name] }, if: :api_type_leaflogix?
  validate  :direct_checkout, if: :api_type_leaflogix?

  scope :owner, lambda { |owner|
    joins(client: :users)
      .merge(User.where(id: owner))
  }

  scope :active, -> { where active: true }

  attr_accessor :regenerate_jti

  before_validation :sanitize_notifications

  before_save :regenerate_jti_token, if: :regenerate_jti
  before_create :build_default_settings, unless: :settings

  after_create :set_webhook_url!
  after_create :schedule_store_sync_job
  after_create :schedule_sync
  after_create :set_sync_frequency
  after_create :create_webhooks, if: :api_type_shopify?

  after_save :schedule_store_sync_job, if: :saved_change_to_api_settings?
  after_save :schedule_sync, if: :change_require_sync_reschedule?
  after_save :schedule_customer_sync, if: :change_require_sync_reschedule?

  after_destroy :delete_webhooks, if: :api_type_shopify?

  def self.from_token_payload(payload)
    store = Store.active.find_by(id: payload['sub'], jti: payload['jti'])

    # raise when not found
    if payload['aud'].blank? || payload['jti'].blank? ||
       !payload['aud'].include?('api') || store.blank?
      raise Knock.not_found_exception_class_name
    end

    store
  end

  def to_token_payload
    payload = { sub: id, aud: [:api], jti: jti }
    payload
  end

  %w[treez headset flowhub leaflogix shopify covasoft blaze].each do |type|
    define_method("api_type_#{type}?") do
      api_type == type
    end
  end

  def api_parser
    if api_type_treez?
      TreezApiParser.new(store_id: id)
    elsif api_type_headset?
      HeadsetApiParser.new(store_id: id)
    elsif api_type_flowhub?
      FlowhubApiParser.new(store_id: id)
    elsif api_type_leaflogix?
      LeaflogixApiParser.new(store_id: id)
    elsif api_type_shopify?
      ShopifyApiParser.new(store_id: id)
    elsif api_type_covasoft?
      CovasoftApiParser.new(store_id: id)
    elsif api_type_blaze?
      BlazeApiParser.new(store_id: id)
    end
  end

  def set_shopify_base_url
    if api_type_shopify?
      ShopifyAPI::Base.site = "https://#{api_key}:#{password}@#{shop_url}/admin"
      ShopifyAPI::Base.api_version = api_version
    end
  end

  def clear_shopify_session
    ShopifyAPI::Base.clear_session if api_type_shopify?
  end

  def csv_parser(file)
    ProductCSVParser.new(file: file, store_id: id)
  end

  def current_sync
    store_syncs.last
  end

  def treez_api_config
    {
      client_id: api_client_id,
      dispensary_name: dispensary_name,
      api_key: api_key,
      api_version: api_version
    }
  end

  def flowhub_api_config
    {
      location_id: location_id,
      client_id: api_client_id,
      auth0_client_id: auth0_client_id,
      auth0_client_secret: auth0_client_secret,
      api_key: api_key
    }
  end

  def leaflogix_api_config
    { api_key: api_key }
  end

  def shopify_api_config
    {
      password: password,
      api_version: api_version,
      shop_url: shop_url
    }
  end

  def covasoft_api_config
    {
      grant_type: grant_type,
      client_cova_id: client_cova_id,
      client_cova_secret: client_cova_secret,
      username: username,
      password_cova: password_cova,
      company_id: company_id,
      location_id_covasoft: location_id_covasoft
    }
  end

  def blaze_api_config
    {
      authorization_blaze: authorization_blaze,
      partner_key_blaze: partner_key_blaze,
    }
  end

  def customer_client
    if api_type_treez?
      Treez::CustomerClient.new(treez_api_config)
    elsif api_type_flowhub?
      Flowhub::CustomerClient.new(flowhub_api_config, customer_type_filter)
    elsif api_type_leaflogix?
      Leaflogix::CustomerClient.new(id, leaflogix_api_config)
    elsif api_type_covasoft?
      Covasoft::CustomerClient.new(covasoft_api_config)
    elsif api_type_blaze?
      Blaze::CustomerClient.new(blaze_api_config)
    end
  end

  def order_client
    if api_type_treez?
      Treez::OrderClient.new(store: self)
    elsif api_type_flowhub?
      Flowhub::OrderClient.new(store: self)
    elsif api_type_leaflogix?
      Leaflogix::OrderClient.new(store: self)
    elsif api_type_shopify?
      Shopify::OrderClient.new(store: self)
    elsif api_type_covasoft?
      Covasoft::OrderClient.new(store: self)
    elsif api_type_blaze?
      Blaze::OrderClient.new(store: self)
    end
  end

  def webhook_endpoint
    if api_type_treez?
      { treez: { single_endpoint: "/stores/#{id}/webhooks/treez/end_point" } }
    elsif api_type_flowhub?
      {} # TODO
    elsif api_type_leaflogix?
      {} # TODO
    elsif api_type_shopify?
      { "products/create": "/stores/#{id}/webhooks/shopify/product_create",
        "products/update": "/stores/#{id}/webhooks/shopify/product_update",
        "products/delete": "/stores/#{id}/webhooks/shopify/product_delete",
        "orders/create": ENV['SHOPIFY_ORDER_WEBHOOK_URL'],
        "orders/updated": ENV['SHOPIFY_ORDER_WEBHOOK_URL'] }
      elsif api_type_blaze?
        { blaze: { single_endpoint: "/stores/#{id}/webhooks/blaze/end_point" } }
      else
      {}
    end
  end

  def schedule_sync
    # Destroy current cron
    Sidekiq::Cron::Job.destroy("catalog_sync_#{id}") if id
    # Schedule the new crom
    if api_type.present? && sync_frequency && active
      Sidekiq::Cron::Job.create(
        name: "catalog_sync_#{id}",
        cron: cron_sync_frequency(sync_frequency, sync_frequency_offset),
        class: 'StoreSyncJob',
        queue: 'stores_sync',
        args: [id]
      )      
    end

    nil
  end
  
  def schedule_customer_sync
    customer_sync_frequency = ENV['CUSTOMER_SYNC_FREQUENCY']
    cron_name = "customer_sync_#{id}"

    # Destroy current cron
    Sidekiq::Cron::Job.destroy(cron_name)

    # Schedule the new crom
    if api_type_leaflogix? && customer_sync_frequency.present? && active
      Sidekiq::Cron::Job.create(
        name: cron_name,
        cron: "*/#{customer_sync_frequency} * * * *", # minutes
        class: 'CustomerSyncJob',
        queue: 'customer_sync',
        args: [id]
      )
    end

    nil
  end

  def schedule_store_sync_job
    job_already_enqueued = false

    queue = Sidekiq::Queue.new('stores_sync')
    queue.each do |job|
      job_already_enqueued = true if job.args[0]['arguments'] == [id]
    end

    StoreSyncJob.perform_later(id) unless job_already_enqueued
  end

  def change_require_sync_reschedule?
    saved_change_to_active? || saved_change_to_api_settings?
  end

  def regenerate_jti_token
    self.jti = SecureRandom.hex if regenerate_jti
  end

  def build_default_settings
    build_settings
    true
  end

  def sanitize_notifications
    self.notifications_send_to_customer = notifications_enabled && notifications_send_to_customer
  end

  protected

  def cron_sync_frequency(frequency, offset)
    frequency = frequency.to_i
    offset = offset.to_i

    if frequency > 0 && frequency < 60
      "#{offset}-59/#{frequency} * * * *"
    elsif frequency >= 60
      hour = frequency / 60
      "#{offset} */#{hour} * * *"
    else
      '0 */3 * * *'
    end
  end

  def set_webhook_url!
    update!(webhook_url: webhook_endpoint)
  end

  def create_webhooks
    CreateShopifyWebhookJob.perform_later(id)
  end

  def delete_webhooks
    set_shopify_base_url

    webhooks = ShopifyAPI::Webhook.find(:all)
    store_webhooks = webhooks.select{|webhook| webhook.address.include?("stores/#{id}/webhooks")}
    Rails.logger.info("Destroying webhooks Store #{id} : #{name}")
    store_webhooks.map{|webhook| webhook.destroy}

    clear_shopify_session
  end

  def set_sync_frequency
    self.api_settings['sync_frequency'] = ENV['STORE_SYNC_FREQ'] if sync_frequency.blank?
    self.api_settings['sync_frequency_offset'] = ENV['STORE_SYNC_FREQ_OFFSET'] if sync_frequency_offset.blank?
  end

  # def customer_exist
  #   if customer_id_changed?
  #     unless order_client.customer_exist?(customer_id)
  #       errors.add(:customer_id, 'Customer does not exist in leaflogix')
  #     end
  #   end
  # end
end

# == Schema Information
#
# Table name: stores
#
#  id                          :bigint           not null, primary key
#  access_token                :string
#  active                      :boolean          default(TRUE)
#  api_settings                :text
#  block_simultaneous_nfc      :boolean          default(FALSE)
#  enable_continuous_cart      :boolean          default(FALSE)
#  enabled_continuous_cart     :boolean          default(FALSE)
#  enabled_share_email_product :boolean          default(FALSE)
#  enabled_share_sms_product   :boolean          default(FALSE)
#  featured_mode               :integer          default("rfid_featured")
#  jti                         :string
#  last_sync_update            :string
#  name                        :string
#  next_initial_sync           :string
#  notification_settings       :text
#  tax                         :text
#  webhook_url                 :json
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  client_id                   :bigint
#
# Indexes
#
#  index_stores_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#

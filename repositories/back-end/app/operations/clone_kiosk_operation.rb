class CloneKioskOperation
  include Dry::Monads[:result, :do]

  def call(source_kiosk, source_store, kiosk_new_name = nil)
    kiosk_n = yield copy_base_attributes(source_kiosk, source_store, kiosk_new_name)

    kiosk_n.layout = yield copy_layout(source_kiosk)

    kiosk_n.save ? Success(kiosk_n) : Failure(kiosk_n.errors)
  end

  private

  def copy_base_attributes(source_kiosk, source_store, kiosk_new_name = nil)
    kiosk = source_kiosk.dup
    kiosk.name = kiosk_new_name != nil ? kiosk_new_name : "Copy of #{source_kiosk.name}"
    if source_store != nil then
      kiosk.store_id = source_store.id
    end
    kiosk.product_filter_criteria = :custom
    kiosk.product_filter_value_id = nil
    kiosk.product_filter_value_type = nil

    Success(kiosk)
  end

  def copy_layout(source_kiosk)
    curr_layout = source_kiosk.layout
    layout = curr_layout.dup

    if curr_layout.welcome_asset.present?
      welcome_asset = curr_layout.welcome_asset.dup
      generate_asset(welcome_asset, curr_layout.welcome_asset) if curr_layout.welcome_asset.asset.present?
      welcome_asset.kiosk_layout = layout
    end

    if curr_layout.navigation.present?
      layout.navigation = curr_layout.navigation.dup
      layout.navigation.items << curr_layout.navigation.items.map(&method(:generate_assets))
    end

    if curr_layout.kiosk_assets.present?
      layout.kiosk_assets << curr_layout.kiosk_assets.map(&method(:generate_kiosk_asset))
    end

    Success(layout)
  end

  def generate_asset(new_asset, old_asset)
    prev_asset = old_asset.asset
    new_asset.asset = clone_url(prev_asset)
  end

  def generate_assets(old_asset)
    new_asset = old_asset.dup
    generate_asset(new_asset, old_asset) if old_asset.asset.present?
    new_asset
  end

  def generate_kiosk_asset(old_asset)
    new_asset = generate_assets(old_asset)
    new_asset.asset_elements << old_asset.asset_elements.map(&method(:generate_assets))
    new_asset
  end

  def clone_url(prev_asset)
    new_key = generate_new_key(prev_asset.url)

    s3 = Aws::S3::Resource.new(region: bucket_region)
    key = key_from_url(prev_asset.url)
    new_object = s3.bucket(bucket_name).object(new_key)
    new_object.copy_from(bucket: bucket_name, key: key, acl: 'public-read')

    new_asset = prev_asset.dup
    new_asset.url = new_object.public_url
    new_asset
  end

  def bucket_name
    ENV['BUCKET_NAME'] || raise_error('BUCKET_NAME must be defined.')
  end

  def bucket_region
    ENV['BUCKET_REGION'] || raise_error('BUCKET_REGION must be defined.')
  end

  def generate_new_key(url)
    key_from_url(url).gsub(%r{([^\/]+\.\w+)$}, "#{SecureRandom.hex(5)}-\\1")
  end

  def key_from_url(url)
    CGI.unescape URI.parse(url).path[1..-1]
  end
end
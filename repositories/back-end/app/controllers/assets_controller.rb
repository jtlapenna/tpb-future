class AssetsController < ApplicationController
  class AssetsException < StandardError
  end

  rescue_from AssetsException do
    render json: {}, status: :unprocessable_entity
  end

  before_action :find_image, only: [:destroy]

  def upload_request
    authorize resource_class

    s3 = Aws::S3::Resource.new(region: bucket_region)
    object = s3.bucket(bucket_name).object(resource_path)
    upload_url = object.presigned_url(:put, acl: 'public-read')

    url_data = { upload_url: upload_url, public_url: object.public_url }

    render json: { url_data: url_data }
  end

  def destroy
    authorize @asset

    @asset.destroy!

    s3 = Aws::S3::Resource.new(region: bucket_region)
    if key = URI.decode(@asset.url.split('/')[-3..-1].join('/'))
      object = s3.bucket(bucket_name).object(key)
      object.delete
    end

    render json: {}
  end

  private

  def find_image
    @asset = policy_scope(resource_class).find(params[:id])
  end

  def resource_path
    "#{resource}/#{SecureRandom.uuid}/#{resource_name}"
  end

  def bucket_name
    ENV['BUCKET_NAME'] || raise_error('BUCKET_NAME must be defined.')
  end

  def bucket_region
    ENV['BUCKET_REGION'] || raise_error('BUCKET_REGION must be defined.')
  end

  def bucket_params
    params.permit(:resource, :resource_name)
  end

  def resource
    raise_error 'Invalid resource' unless valid_resources.include?(bucket_params[:resource])
    bucket_params[:resource]
  end

  def resource_name
    raise_error 'resource_name is required' if bucket_params[:resource_name].blank?
    bucket_params[:resource_name]
  end

  def valid_resources
    %w[products stores store_products kiosk_product_layout_media store_categories ad_banners]
  end

  def raise_error(msg = '')
    raise AssetsException, msg
  end

  def resource_class
    if params[:resource_type] == 'asset'
      Asset
    else
      Image
    end
  end
end

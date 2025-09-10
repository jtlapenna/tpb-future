module Api
    module V1
      class AdBannerSerializer < ActiveModel::Serializer
        attributes :id, 
        :ad_banner_location, 
        :ad_banner_location_id, 
        :text, 
        :images,         
        :callback_url, 
        :disabled, 
        :advertisable,
        :advertisable_id,
        :advertisable_type,
        :advertisable_image
      end
    end
  end
  
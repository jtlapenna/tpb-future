module Api
    module V1
      class AdBannerLocationSerializer < ActiveModel::Serializer
        attributes :id, :text, :codename, :special_type
      end
    end
  end
  
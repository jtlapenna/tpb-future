module Api
  module V1
    class ProductValueSerializer < ActiveModel::Serializer
      attributes :id, :name, :value, :created_at, :updated_at
    end
  end
end

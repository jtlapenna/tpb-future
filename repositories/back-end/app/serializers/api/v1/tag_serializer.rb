module Api
  module V1
    class TagSerializer < ActiveModel::Serializer
      attributes :tag, :description, :created_at, :updated_at
    end
  end
end

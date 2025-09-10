module Api
  module V1
    class ReviewSerializer < ActiveModel::Serializer
      attributes :user, :rate, :text, :created_at, :updated_at
    end
  end
end

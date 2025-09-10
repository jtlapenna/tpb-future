class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :user, :rate, :text, :reviewable_type, :reviewable_id
end

class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true

  validates :text, presence: true
end

# == Schema Information
#
# Table name: reviews
#
#  id              :bigint           not null, primary key
#  rate            :string
#  reviewable_type :string
#  text            :string
#  user            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reviewable_id   :bigint
#
# Indexes
#
#  index_reviews_on_reviewable_type_and_reviewable_id  (reviewable_type,reviewable_id)
#

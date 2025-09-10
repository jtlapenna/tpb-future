module Reviewable
  extend ActiveSupport::Concern

  included do
    has_many :reviews, as: :reviewable, inverse_of: :reviewable, dependent: :nullify
    accepts_nested_attributes_for :reviews, allow_destroy: true, reject_if: :all_blank
  end
end

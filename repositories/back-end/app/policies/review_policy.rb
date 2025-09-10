class ReviewPolicy < ApplicationPolicy
  def permitted_attributes
    %i[
      user rate text reviewable_id reviewable_type
    ]
  end
end

class ActsAsTaggableOn::TagPolicy < ApplicationPolicy
  def index?
    user
  end
end

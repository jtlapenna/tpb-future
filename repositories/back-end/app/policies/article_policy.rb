class ArticlePolicy < ApplicationPolicy
  def index?
    user
  end

  def show?
    user
  end

  def permitted_attributes
    %i[title text tag icon excerpt category_id]
  end
end

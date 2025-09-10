class UsersController < ApplicationController
  include Paged
  include Sortable

  def current
    render json: current_user
  end

  def index
    authorize User
    users = policy_scope(User).page(page).per(page_size).order(order_fields)

    render json: users, meta: pagination_dict(users)
  end

  def create
    authorize User

    new_user = User.new(permitted_attributes(User))

    if new_user.save
      render json: new_user, status: :created
    else
      errors = new_user.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize user

    if @user.update(permitted_attributes(@user))
      render json: user
    else
      errors = user.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize user
    render json: user
  end

  private

  def user
    @user ||= policy_scope(User).find(params[:id])
  end
end

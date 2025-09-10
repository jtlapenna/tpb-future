class ReviewsController < ApplicationController
  include Paged
  include Sortable

  before_action :find_review, only: %i[show update]

  def index
    authorize Review
    reviews = policy_scope(Review).page(page).per(page_size).order(order_fields)

    render json: reviews, meta: pagination_dict(reviews)
  end

  def create
    authorize Review
    review = Review.new(permitted_attributes(Review))

    if review.save
      render json: review, status: :created
    else
      errors = review.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @review
    if @review.update(permitted_attributes(@review))
      render json: @review
    else
      errors = @review.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @review
    render json: @review
  end

  private

  def find_review
    @review ||= policy_scope(Review).find(params[:id])
  end
end

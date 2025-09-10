module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from Pundit::NotAuthorizedError, with: :forbidden
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActiveModel::ValidationError,
                with: ->(ex) { unprocessable_entity(ex.model.errors.as_json) }
  end

  protected

  def record_not_found
    render json: { error: { message: 'Resource not found' } }, status: :not_found
  end

  def unprocessable_entity(errors = {})
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def forbidden(exception)
    policy_name = exception.policy.class.to_s.underscore
    message = I18n.t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default

    render json: { status: 403, message: message }, status: :forbidden
  end

  def bad_request(exception)
    render json: { status: 400, message: exception.message }, status: :bad_request
  end
end

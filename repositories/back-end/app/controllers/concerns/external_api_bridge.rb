module ExternalApiBridge
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::ExternalApiError, with: :api_integration_error
    rescue_from Errors::ResourceNotUnique, with: :duplicate_resource
  end

  def duplicate_resource(ex)
    message = I18n.t "#{ex.type}.not_unique", scope: 'integration.errors', default: 'not unique'

    render json: { status: 409, message: message }, status: :conflict
  end

  def api_integration_error(ex)
    Rails.logger.error ex
    message = I18n.t(
      'unexpected',
      scope: 'integration.errors',
      message: ex.message,
      default: 'unexpected problem'
    )

    render json: { status: 502, message: message }, status: :bad_gateway
  end
end

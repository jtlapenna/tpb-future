class UserTokenController < Knock::AuthTokenController
  skip_before_action :verify_authenticity_token

  def create
    render json: auth_response, status: :created
  end

  private

  def auth_response
    user_serializer = ActiveModelSerializers::SerializableResource.new(entity)

    { jwt: auth_token.token }.merge user_serializer.as_json
  end
end

module RequestsHelper
  module JsonHelpers
    def json
      raw = response ? response.body : response_body
      @json ||= JSON.parse(raw)
    end
  end

  module AuthHelpers
    def auth_token(entity)
      payload = { sub: entity.id, aud: [:backend] }
      if entity.is_a?(Store)
        payload[:aud] = [:api]
        payload[:jti] = entity.jti
      end
      Knock::AuthToken.new(payload: payload).token
    end

    # This works work controllers specs
    def authenticate(entity)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{auth_token(entity)}"
    end

    # Use this for requests specs
    def auth_headers(entity, as_json: false)
      headers = { 'Authorization' => "Bearer #{auth_token(entity)}" }
      headers['CONTENT_TYPE'] = 'application/json' if as_json
      headers
    end

    def invalid_auth_headers(entity)
      { 'Authorization' => "Bearer #{auth_token(entity)}1" }
    end
  end
end

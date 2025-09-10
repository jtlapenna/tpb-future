module Api
  module V1
    class HealthController < ApplicationController
      def index
        render json: { status: 'ok', timestamp: Time.current }
      end

      def ping
        render json: { message: 'pong' }
      end
    end
  end
end 
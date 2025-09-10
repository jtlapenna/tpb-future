class Api::V1::ApplicationController < ActionController::API



  include Knock::Authenticable
  include Rescuable
  before_action :render_error_when_invalid_auth_token, :except => [:ping]
  before_action :authenticate_store, :except => [:ping]
  
  def ping
    output = {'pong' => Time.now}.to_json
    render :json => output
  end



 
  def stats
    render json: ActiveRecord::Base.connection_pool.stat
  end
  protected

  def render_error_when_invalid_auth_token
    auth = params[:token] || request.headers['Authorization']
    if auth.blank?
      render(
        json: { error: { message: 'Authorization token not present' } },
        status: :unauthorized
      )
    end
  end

  def kiosk
    current_store.kiosks.find(params[:catalog_id]) if params[:catalog_id]
  end
end

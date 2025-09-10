class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Pundit
  include Rescuable

  before_action :authenticate_user
end

module KioskRequired
  extend ActiveSupport::Concern

  attr_accessor :kiosk

  included do
    before_action :find_kiosk
  end

  private

  def find_kiosk
    @kiosk ||= policy_scope(Kiosk).find(params[:kiosk_id])
  end
end

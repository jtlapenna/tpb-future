class Api::V1::OrdersController < Api::V1::ApplicationController
  include ExternalApiBridge

  before_action :find_client
  before_action :require_client
  after_action :notify_by_email, only: :create
  before_action :customer_order_with_order_id, only: [:status]
  before_action :allowed_status_value, only: [:status]
  before_action :find_order, only: [:update]

  def create
    create_params # check params

    if @order_client&.support_resume? && customer_order&.order_id
      old_order = @order_client.get(customer_order.order_id)
    end

    if order_in_progress?(old_order)
      order = @order_client.update!(merge_orders(create_params, old_order))
      customer_order.update(
        data: order[:data]
      )
    elsif @order_client.present?
      order = @order_client.create!(create_params)
      CustomerOrder.create(
        order_id: order[:id],
        customer_id: order[:customer_id],
        store: kiosk.store,
        data: order[:data]
      )
    end

    render json: { order: order || create_params }, status: :ok
  end

  def update
    order = @found_customer_order.update(update_params)

    render json: { order: order || status_params }, status: :ok
  end

  def status
    order = @order_client.update_status!(status_params)

    render json: { order: order || status_params }, status: :ok
  end

  def preview_order
    preview_params = {
     "type" => order_type,
      "order_source" => order_source,
      "order_status" => "AWAITING_PROCESSING",
      "store_id" => kiosk.store.id,
    }.merge(preview_order_params)

    preview_data = @order_client.preview!(preview_params)

    render json: { order: preview_data }, status: :ok
  end

  def discount
    res = @order_client.search_coupon(params.slice(:code))
    if res.present?
      render json: { price_rule: res }, status: :ok
    else
      render json: { error: { message: 'Discount code not found' } }, status: :not_found
    end
  end

  private

  def order_in_progress?(order = nil)
    if kiosk.store.api_type_treez?
      @in_progress ||= order && order[:status].upcase == 'AWAITING_PROCESSING' && order[:customer_id].present?
    elsif kiosk.store.api_type_covasoft?
      @in_progress ||= order && order[:status] == 'Confirmed'
    end
  end

  def notify_by_email
    return unless kiosk.store.notifications_enabled

    OrdersMailer.notify_new_order(
      store_id: kiosk.store.id,
      order: notify_params,
      is_update: order_in_progress?
    )
  end

  def customer_order
    @customer_order ||= CustomerOrder.sorted
                                     .find_by(
                                       customer_id: params[:order][:customer_id],
                                       store: kiosk.store
                                     )
  end

  def customer_order_with_order_id
    @customer_order ||= CustomerOrder.find_by(customer_id: params[:order][:customer_id], order_id: params[:order][:ticket_id], store: kiosk.store)

    unless @customer_order.present?
      render json: { error: { message: 'Customer order not found' } }, status: :not_found
    end
  end

  def allowed_status_value
    unless CustomerOrder::ALLOWED_STATUS.include?(params[:order][:order_status])
      render json: { status: 400, message: 'Order Status value is not allowed' }, status: :bad_request
    end
  end

  def merge_orders(new_order, old_order)
    all_items = old_order[:items].concat(new_order[:items])

    items_result = all_items.group_by { |item| item[:product_id].to_s }.map do |_product_id, items|
      if items.count > 1 # if we have only 1 items, we don't need recalculate quantities
        item_with_id = items.detect { |item| item[:id].present? } || items.first
        item_with_id[:quantity] = items.sum { |item| item[:quantity].to_i }
        item_with_id
      else
        items.first
      end
    end

    old_order[:items] = items_result
    old_order
  end

  def find_client
    @order_client = kiosk.store.order_client
  end

  def require_client
    if @order_client.blank? && !kiosk.store.notifications_enabled
      message = I18n.t 'errors.not_allowed', scope: 'integration', default: 'method not allowed'
      render json: { status: 405, message: message }, status: :method_not_allowed
    end
  end

  def find_order
    @found_customer_order ||= CustomerOrder.where(order_id: params[:id], store_id: kiosk.store.id)
  end

  def create_params
    params.require(:order).permit(
      :order_number, :customer_id, :notes, :cart_id,
      items: %i[product_id quantity product_value_id]
    ).to_h
  end

  def notify_params
    params.require(:order).permit(
      :order_number, :customer_id, :customer_name, :customer_email,
      items: %i[product_id quantity product_value_id]
    ).to_h
  end

  def status_params
    params.require(:order).permit(
      :customer_id, :order_status, :ticket_id
    ).to_h
  end

  def update_params
    params.require(:order).permit(
      :printed_date, :printed_id
    ).to_h
  end

  def preview_order_params
    params.require(:order).permit(
      :type, :order_source, :order_status, :external_order_number,
      :customer_id, :ticket_note, :delivery_address, :scheduled_date,
      created_by_employee: {},
      delivery_address: {},
      items: [:location_name, :size_id, :quantity, :apply_automatic_discounts,
              :price_target, :price_target_note, :inventory_id, :inventory_batch_id,
              :inventory_type, :price, :unit_price, :is_recreational_product,
              POS_discounts: [:discount_title, :discount_amount, :discount_method]]
    ).to_h
  end

  def order_source
    params[:order][:order_source] || 'IN_STORE'
  end

  def order_type
    params[:order][:type] || 'POS'
  end
end

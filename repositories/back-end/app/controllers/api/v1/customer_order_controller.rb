class Api::V1::CustomerOrderController < Api::V1::ApplicationController
  include Paged
  include Sortable
  include Searchable

  def index
    order = OrderCustomer.all
    if(params[:q].present?)
      order = order.where("uuid LIKE ?", "%#{params[:q]}%")
    end
    order = order.page(page).per(page_size).order(order_fields)
    render json: order,meta: pagination_dict(order)
  end

  def create
      kiosks = Kiosk.find(params[:order][:kiosks_id])
      @order = OrderCustomer.new(order_params)
      if @order.save
          params[:order][:products].each do |product|
          store_products = StoreProduct.where(sku: product[:sku]).first
         
          if params[:order][:products].present?
              $order_params = order_params.merge(order_customers_id: @order.id, store_products_id:store_products.id, quantity: product[:quantity], product_value_id: product[:product_value_id])
              @customer_order_store_product = CustomerOrderStoreProduct.new($order_params)
              @customer_order_store_product.save
        end
        end
        render json: @order, status: :created
      else
        render json: @order.errors, status: :unprocessable_entity
      end
  end

  def update
    $order = OrderCustomer.find(params[:id])
    $order.update(order_params_update)
    if($order.save)
      render json: $order
    else
      render json: { message: 'Order not updated' }
    end
  end

  def order_params
    params.require(:order).permit(:kiosks_id, :first_name, :last_name, :amount, :products,:client_id).merge(uuid: SecureRandom.uuid, payed: false, date: Time.zone.now)
  end

  def order_params_update
    params.require(:order).permit(:payed)
  end
end
class OrdersMailer < ApplicationMailer
  layout 'mailer'

  def new_order(store_id:, order: {}, is_update: false, customer_email: nil)
    store = Store.find store_id

    return unless store.notifications_enabled

    @settings = store.notification_settings
    @order = order
    @is_update = is_update
    @is_for_customer = customer_email

    calculte_total_price_item_of_order @order[:items]

    date = I18n.l(Date.today, format: :notification_email)
    subject = "#{store.notifications_title} [#{@order[:customer_name]} - #{date}]"

    to = customer_email ? [customer_email] : store.notifications_recipients

    mail to: to, subject: subject
  end

  def self.notify_new_order(store_id:, order: {}, is_update: false)
    store = Store.find store_id

    new_order(store_id: store_id, order: order, is_update: is_update).deliver_later

    if store.notifications_send_to_customer
      new_order(
        store_id: store_id,
        order: order,
        is_update: is_update,
        customer_email: order[:customer_email]
      ).deliver_later
    end
  end

  private

  def calculte_total_price_item_of_order(items = [])
    items.each do |item|
      next if item[:price_total]

      store_product = StoreProduct.find_by(id: item[:product_id])

      product_value = if item[:product_value_id].present?
                        store_product.product_values.find_by(id: item[:product_value_id])
                      else
                        store_product.product_values.first
                      end

      item[:price_total] = item[:quantity].to_i * ((product_value && product_value.value) || 0)
    end
  end
end

class Api::V1::CartsController < Api::V1::ApplicationController
  def validate
    result = CartContract.new(store: store).call(cart: cart_params)

    json = response_api(result)

    render json: json, status: :ok
  end

  def index
    if params[:phone_number].nil?
      render json: { errors: "Phone number is missing" }, status: :unprocessable_entity
      return
    end

    cart = Cart.find_by(phone_number: params[:phone_number], is_active: true)
    if cart.nil?
      render json: { errors: "No active cart found" }, status: :not_found
      return
    end

    cart_items = cart.cart_items.map do |item|
      {
        id: item.id,
        product_id: item.store_product_id,
        quantity: item.quantity
      }
    end

    render json: {
      **cart.as_json,
      cart_items: cart_items
    }, status: :ok
  end

  def create_or_merge
    if params[:phone_number].nil?
      render json: { errors: "Phone number is missing" }, status: :unprocessable_entity
      return
    end

    if Cart.exists?(is_active: true, phone_number: params['phone_number'])
      add_items
      return
    end

    cart = Cart.new(phone_number: params[:phone_number], is_active: true)

    if cart.save
      result = CartContract.new(store: store).call(cart: cart_params)

      if not result.success?
        json = response_api(result)
        render json: json, status: :unprocessable_entity
        return
      end
      cart = Cart.find_by(phone_number: params['phone_number'], is_active: true)

      items = cart_params[:items]
      items.each do |item|
        if item[:product_id].nil?
          render json: { errors: "Product ID is missing for one of the items" }, status: :unprocessable_entity
          return
        end

        product = store.store_products.find_by(id: item[:product_id])
        unless product
          render json: { errors: "Product with ID #{item[:product_id]} does not exist" }, status: :unprocessable_entity
          return
        end

        cart_item = cart.cart_items.find_or_initialize_by(store_product_id: item[:product_id])
        if cart_item.new_record?
          cart_item.quantity = item[:quantity]
        else
          cart_item.quantity += item[:quantity]
        end
        unless cart_item.save
          render json: { errors: cart_item.errors.as_json }, status: :unprocessable_entity
          return
        end
      end
      cart_items = cart.cart_items.map do |item|
        {
          id: item.id,
          product_id: item.store_product_id,
          quantity: item.quantity
        }
      end

      render json: {
        **cart.as_json,
        is_new: true,
        cart_items: cart_items
      }, status: :ok
    else
      errors = cart.errors.as_json
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def add_items
    if params[:phone_number].nil?
      render json: { errors: "Phone number is missing" }, status: :unprocessable_entity
      return
    end

    if params[:cart].nil?
      render json: { errors: "Cart items are missing" }, status: :unprocessable_entity
      return
    end

    if not Cart.exists?(is_active: true, phone_number: params['phone_number'])
      render json: { errors: "Active Cart doesn't exist" }, status: :unprocessable_entity
      return
    end

    result = CartContract.new(store: store).call(cart: cart_params)

    if not result.success?
      json = response_api(result)
      render json: json, status: :unprocessable_entity
    end

    cart = Cart.find_by(phone_number: params['phone_number'], is_active: true)

    items = cart_params[:items]
    items.each do |item|
      if item[:product_id].nil?
        render json: { errors: "Product ID is missing for one of the items" }, status: :unprocessable_entity
        return
      end

      product = store.store_products.find_by(id: item[:product_id])
      unless product
        render json: { errors: "Product with ID #{item[:product_id]} does not exist" }, status: :unprocessable_entity
        return
      end

      cart_item = cart.cart_items.find_or_initialize_by(store_product_id: item[:product_id])
      if cart_item.new_record?
        cart_item.quantity = item[:quantity]
      else
        cart_item.quantity += item[:quantity]
      end
      unless cart_item.save
        render json: { errors: cart_item.errors.as_json }, status: :unprocessable_entity
        return
      end
    end

    cart_items = CartItem.where(cart_id: cart.id).map do |item|
      {
        id: item.id,
        product_id: item.store_product_id,
        quantity: item.quantity
      }

    end
    # Force update the cart updated_at field to avoid it being cleaned up by the CleanActiveCartsJob
    cart.updated_at = Time.now
    cart.save
    Rails.logger.info("Cart Items successfully added: #{cart_items} to cart: #{cart.id}")
    render json: {
      **cart.as_json,
      cart_items: cart_items
    }, status: :ok
  end

  def update_item
    if params[:phone_number].nil?
      render json: { errors: "Phone number is missing" }, status: :unprocessable_entity
      return
    end

    if params[:product_id].nil?
      render json: { errors: "Product ID is missing" }, status: :unprocessable_entity
      return
    end

    cart = Cart.find_by(phone_number: params[:phone_number], is_active: true)
    if cart.nil?
      render json: { errors: "No active cart found" }, status: :not_found
      return
    end

    product = store.store_products.find_by(id: params[:product_id])
    if product.nil?
      render json: { errors: "Product with ID #{params[:product_id]} does not exist" }, status: :unprocessable_entity
      return
    end

    cart_item = cart.cart_items.find_by(store_product_id: params[:product_id])
    if cart_item.nil?
      render json: { errors: "Product with ID #{params[:product_id]} not found in cart" }, status: :not_found
      return
    end

    if params[:quantity] == 0
      cart_item.destroy
    else
      cart_item.quantity = params[:quantity]
      cart_item.save
    end
    cart_items = CartItem.where(cart_id: cart.id).map do |item|
      {
        id: item.id,
        product_id: item.store_product_id,
        quantity: item.quantity
      }
    end

    render json: {
      **cart.as_json,
      cart_items: cart_items
    }, status: :ok
  end

  def exists
    if params[:phone_number].nil?
      render json: { errors: "Phone number is missing" }, status: :unprocessable_entity
      return
    end

    cart = Cart.find_by(phone_number: params[:phone_number], is_active: true)
    render json: { exists: !cart.nil? }, status: :ok
  end

  private

  def cart_params
    params.require(:cart).permit(items: %i[product_id quantity]).to_h
  end

  def store
    kiosk.store
  end

  def response_api(result)
    return { success: true } if result.success?

    messages = result.errors.messages.map do |message|
      path = message.path.join('.')

      { path: path, message: message.text }.merge(message.meta)
    end

    errors = messages.group_by { |e| e[:path] }.each { |_, v| v.each { |message| message.delete(:path) } }

    {
      success: false,
      message: result.errors.messages.first.text,
      errors: errors
    }
  end

end

class KioskProductLayoutsController < ApplicationController
  include KioskRequired

  attr_reader :product

  before_action :find_product

  def show
    authorize :kiosk_product_layout

    render json: product,
           serializer: KioskProductLayoutSerializer,
           root: 'layout',
           include: serializer_includes
  end

  def update
    authorize :kiosk_product_layout

    product.update!(
      stylesheet: layout_params[:stylesheet],
      product_layout_values_attributes: layout_params[:values]
    )

    render json: product,
           serializer: KioskProductLayoutSerializer,
           root: 'layout',
           include: serializer_includes
  end

  private

  def layout_params
    params.require(:kiosk_product_layout)
          .permit(policy(:kiosk_product_layout).permitted_attributes)
  end

  def find_product
    @product ||= policy_scope(kiosk.kiosk_products).find(params[:kiosk_product_id])
  end

  def serializer_includes
    'values.asset'
  end
end

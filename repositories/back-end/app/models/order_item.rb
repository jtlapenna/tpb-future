class OrderItem
  include ExternalModel

  attr_accessor :product_id, :quantity, :order, :product_value_id

  delegate :store_id, to: :order, allow_nil: true

  validates :product_id, :quantity, presence: true
  validates :quantity, numericality: true, allow_blank: true
  validate :validate_product_exists, if: :product_id?

  def attributes
    {
      'product_id' => nil, 'quantity' => nil, 'order' => nil
    }
  end

  def product
    return unless product_id

    @product ||= StoreProduct.find_by(id: product_id, store_id: store_id)
  end

  private

  def validate_product_exists
    errors.add :product_id, :not_found unless product
  end

  def product_id?
    product_id.present?
  end
end

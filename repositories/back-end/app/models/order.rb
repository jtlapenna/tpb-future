class Order
  include ExternalModel

  attr_accessor :customer_id, :items, :store_id, :id

  validates :store_id, :items, presence: true
  validate :validate_items

  def attributes
    {
      'customer_id' => nil, 'items' => nil, 'store_id' => nil, 'id' => nil
    }
  end

  def new_record?
    id.blank?
  end

  def items=(value)
    @items = (value || []).map { |item| OrderItem.new(item.merge(order: self)) }
  end

  protected

  def validate_items
    items.reject(&:valid?).each_with_index do |item, _index|
      item.errors.each do |attribute, message|
        attribute_name = "items.#{attribute}"

        errors[attribute_name] << message
        errors[attribute_name].uniq!
      end
    end
  end
end

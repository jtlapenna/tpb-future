class RfidProductSerializer < ActiveModel::Serializer
  attributes :id, :rfid, :rfid_entity_id, :rfid_entity_type, :order

  attribute :rfid_sub_entity_id, if: :has_rfid_sub_entity_id?
  attribute :name, if: :has_rfid_sub_entity_id?

  attribute :stock do
    @object.rfid_entity&.stock if @object.rfid_entity_type == KioskProduct.name
  end

  attribute :name do
    if @object.rfid_entity_type == KioskProduct.name
      @object.rfid_entity&.name_for_catalog
    elsif @object.rfid_entity_type == "BrandAndStoreCategory"
      @object.name
    else
      @object.rfid_entity&.name
    end
  end

  def rfid_sub_entity_id
    object.rfid_sub_entity_id if object.respond_to?(:rfid_sub_entity_id)
  end

  def has_rfid_sub_entity_id?
    object.respond_to?(:rfid_sub_entity_id)
  end

  def rfid_name
    object.name if object.respond_to?(:name)
  end

  def has_name?
    object.respond_to?(:name)
  end
end

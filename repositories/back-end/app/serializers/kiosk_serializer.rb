class KioskSerializer < ActiveModel::Serializer
  attributes :id, :name, :tag_list, :sensor_method, :sensor_threshold, :rfid_sorting, :rfid_behavior, :location,
             :product_filter_criteria, :product_filter_value_type, :product_filter_value_id,
             :product_layout_id

  belongs_to :store, serializer: StoreMinimalSerializer

  has_one :layout
end

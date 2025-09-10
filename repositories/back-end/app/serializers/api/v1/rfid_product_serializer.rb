module Api
  module V1
    class RfidProductSerializer < ActiveModel::Serializer
      attributes :code, :kiosk_product_id, :product_id, :created_at, :updated_at, :rfid_entity_id, :rfid_entity_type, :stock, :order

      def code
        @object.rfid
      end

      def product_id
         @object.store_product_id
      end
      def stock
        @object.stock
      end
      def kiosk_product_id
        @object.rfid_entity_id
      end
    end
  end
end

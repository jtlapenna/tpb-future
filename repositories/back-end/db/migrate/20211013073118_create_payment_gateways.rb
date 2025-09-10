class CreatePaymentGateways < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_gateways do |t|
      t.belongs_to :store, null: false, foreign_key: true
      t.belongs_to :payment_gateway_provider, null: false, foreign_key: true
      t.json :api_settings

      t.timestamps
    end
  end
end

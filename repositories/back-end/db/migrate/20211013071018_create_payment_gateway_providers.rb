class CreatePaymentGatewayProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_gateway_providers do |t|
      t.string :name
      t.string :fields, array: true, default: []

      t.timestamps
    end
  end
end

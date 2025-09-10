class AddEnabledProjectsToPaymentGateways < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_gateways, :projects, :string, array: true, default: []
  end
end

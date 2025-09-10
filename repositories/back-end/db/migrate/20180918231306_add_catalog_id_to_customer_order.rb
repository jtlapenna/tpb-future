class AddCatalogIdToCustomerOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :customer_orders, :catalog, foreign_key: true
  end
end

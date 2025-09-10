class AddToCustomersIndexByLowerEmail < ActiveRecord::Migration[6.0]
  def change
    add_index :customers, 'lower(email)', name: :index_customers_on_lowercase_email
  end
end

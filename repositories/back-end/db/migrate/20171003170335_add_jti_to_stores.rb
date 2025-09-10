class AddJtiToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :jti, :string
  end
end

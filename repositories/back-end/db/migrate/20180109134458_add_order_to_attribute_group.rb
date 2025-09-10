class AddOrderToAttributeGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :attribute_groups, :order, :integer
  end
end

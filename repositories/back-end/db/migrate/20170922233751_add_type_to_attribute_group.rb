class AddTypeToAttributeGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :attribute_groups, :group_type, :integer, default: 0
  end
end

class AddRestrictedToAttributeDef < ActiveRecord::Migration[5.1]
  def change
    add_column :attribute_defs, :restricted, :boolean, default: false
  end
end

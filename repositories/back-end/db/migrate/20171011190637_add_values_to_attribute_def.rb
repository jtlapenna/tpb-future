class AddValuesToAttributeDef < ActiveRecord::Migration[5.1]
  def change
    add_column :attribute_defs, :values, :string
  end
end

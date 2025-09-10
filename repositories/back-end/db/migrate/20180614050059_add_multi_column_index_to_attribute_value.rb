class AddMultiColumnIndexToAttributeValue < ActiveRecord::Migration[5.1]
  def change
    add_index :attribute_values, [:target_id, :target_type]
    add_index :attribute_values, [:target_id, :target_type, :attribute_def_id], name: :index_attribute_values_on_target_and_def
  end
end

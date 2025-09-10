class AddIndexToAttributeDefName < ActiveRecord::Migration[5.1]
  def change
    add_index :attribute_defs, "lower((name)::text) varchar_pattern_ops", name: :index_attribute_defs_on_name
  end
end

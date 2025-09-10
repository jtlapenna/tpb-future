class CreateAttributeValues < ActiveRecord::Migration[5.1]
  def change
    create_table :attribute_values do |t|
      t.string :value
      t.references :attribute_def, foreign_key: true
      t.integer :target_id
      t.string :target_type

      t.timestamps
    end

    add_index :attribute_values, :target_id
    add_index :attribute_values, :target_type
  end
end

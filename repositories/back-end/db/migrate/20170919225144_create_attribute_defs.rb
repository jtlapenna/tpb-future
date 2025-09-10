class CreateAttributeDefs < ActiveRecord::Migration[5.1]
  def change
    create_table :attribute_defs do |t|
      t.string :name
      t.references :attribute_group, foreign_key: true

      t.timestamps
    end
  end
end

class CreateAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :assets do |t|
      t.string :url
      t.integer :source_id
      t.string :source_type

      t.timestamps
    end
  end
end

class CreateFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :favorites do |t|
      t.string :user_id, null: false
      t.belongs_to :store, null: false
      t.belongs_to :product, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end

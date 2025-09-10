class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.string :user
      t.string :rate
      t.string :text
      t.references :reviewable, polymorphic: true

      t.timestamps
    end
  end
end

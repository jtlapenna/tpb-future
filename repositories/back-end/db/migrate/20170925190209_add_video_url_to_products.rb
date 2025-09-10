class AddVideoUrlToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :video_url, :string
  end
end

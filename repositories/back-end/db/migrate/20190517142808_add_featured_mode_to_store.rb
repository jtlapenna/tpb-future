class AddFeaturedModeToStore < ActiveRecord::Migration[5.2]
  def change
    add_column :stores, :featured_mode, :integer, default: 0
  end
end

class AddIndexIncasesensitiveToBrand < ActiveRecord::Migration[5.2]
  def change
    add_index :brands, "replace(lower(name), ' ', '')", name: :index_brand_on_name_case_space_insensitive
  end
end

class ReplaceProductElementProductLayoutTabWithSource < ActiveRecord::Migration[5.2]
  def up
    add_reference :product_layout_elements, :source, polymorphic: true, index: true

    execute("UPDATE product_layout_elements SET source_id = product_layout_tab_id, source_type = 'ProductLayoutTab'")

    remove_reference :product_layout_elements, :product_layout_tab
  end

  def down
    add_reference :product_layout_elements, :product_layout_tab, foreign_key: true

    execute("UPDATE product_layout_elements SET product_layout_tab_id = source_id WHERE source_type = 'ProductLayoutTab'")
    execute("DELETE product_layout_elements WHERE source_type != 'ProductLayoutTab'")

    remove_reference :product_layout_elements, :source, polymorphic: true, index: true
  end
end

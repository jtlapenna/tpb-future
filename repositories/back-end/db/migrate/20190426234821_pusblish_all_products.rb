class PusblishAllProducts < ActiveRecord::Migration[5.2]
  class CatalogProduct < ApplicationRecord
    enum status: { unpublished: 0, published: 1 }
  end

  def up
    CatalogProduct.all.update_all(status: CatalogProduct.statuses[:published])
  end

  def down
  end
end

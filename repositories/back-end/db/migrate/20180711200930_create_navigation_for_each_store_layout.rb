class CreateNavigationForEachStoreLayout < ActiveRecord::Migration[5.1]
  class StoreLayout < ApplicationRecord
    has_one :navigation, class_name: LayoutNavigation.name
    accepts_nested_attributes_for :navigation
  end

  def up
    StoreLayout.find_each do |sl|
      sl.create_navigation! unless sl.navigation.present?
    end
  end

  def down
  end
end

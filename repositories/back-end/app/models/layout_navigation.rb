class LayoutNavigation < ApplicationRecord
  belongs_to :kiosk_layout

  has_many :items, class_name: 'LayoutNavigationItem', dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true,
                                        reject_if: lambda { |a|
                                          a.except(:order).all? { |_k, v| v.blank? }
                                        }
end

# == Schema Information
#
# Table name: layout_navigations
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  kiosk_layout_id :bigint
#
# Indexes
#
#  index_layout_navigations_on_kiosk_layout_id  (kiosk_layout_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_layout_id => kiosk_layouts.id)
#

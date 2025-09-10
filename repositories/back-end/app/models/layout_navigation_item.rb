class LayoutNavigationItem < ApplicationRecord
  belongs_to :layout_navigation

  has_one :asset, as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank
end

# == Schema Information
#
# Table name: layout_navigation_items
#
#  id                   :bigint           not null, primary key
#  description          :string
#  label                :string
#  link                 :string
#  order                :integer          default(0)
#  title                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  layout_navigation_id :bigint
#
# Indexes
#
#  index_layout_navigation_items_on_layout_navigation_id  (layout_navigation_id)
#
# Foreign Keys
#
#  fk_rails_...  (layout_navigation_id => layout_navigations.id)
#

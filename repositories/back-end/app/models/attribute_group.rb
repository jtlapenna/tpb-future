class AttributeGroup < ApplicationRecord
  has_many :attribute_defs, dependent: :destroy

  enum group_type: { short_text: 0, long_text: 1 }

  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: attribute_groups
#
#  id         :bigint           not null, primary key
#  group_type :integer          default("short_text")
#  name       :string
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

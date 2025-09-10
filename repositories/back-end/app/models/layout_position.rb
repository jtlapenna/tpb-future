class LayoutPosition < ApplicationRecord
  validates :label, presence: true
end

# == Schema Information
#
# Table name: layout_positions
#
#  id         :bigint           not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

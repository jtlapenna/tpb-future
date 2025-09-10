class TagInfo < ApplicationRecord
  validates :tag, :description, presence: true

  validates :tag, uniqueness: { message: 'Tag already exists.' }
end

# == Schema Information
#
# Table name: tag_infos
#
#  id          :bigint           not null, primary key
#  description :text
#  tag         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_tag_infos_on_tag  (tag) UNIQUE
#

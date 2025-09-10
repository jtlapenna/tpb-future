class AttributeDef < ApplicationRecord
  has_paper_trail on: [:destroy]

  belongs_to :attribute_group, optional: true
  has_many :attribute_values, dependent: :destroy

  serialize :values, Array

  validates :name, presence: true
  validates :values, presence: true, if: :restricted

  before_save :clean_values, unless: :restricted

  scope :by_name, ->(name) { where 'lower(name) = ?', name.to_s.downcase }

  private

  def clean_values
    self.values = nil
  end
end

# == Schema Information
#
# Table name: attribute_defs
#
#  id                 :bigint           not null, primary key
#  name               :string
#  restricted         :boolean          default(FALSE)
#  values             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  attribute_group_id :bigint
#
# Indexes
#
#  index_attribute_defs_on_attribute_group_id  (attribute_group_id)
#  index_attribute_defs_on_name                (lower((name)::text) varchar_pattern_ops)
#
# Foreign Keys
#
#  fk_rails_...  (attribute_group_id => attribute_groups.id)
#

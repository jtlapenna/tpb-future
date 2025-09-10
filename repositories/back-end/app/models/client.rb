class Client < ApplicationRecord
  has_many :stores, inverse_of: :client, dependent: :nullify
  has_many :users, dependent: :nullify

  validates :name, uniqueness: true, presence: true
end

# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  active     :boolean
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

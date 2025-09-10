class User < ApplicationRecord
  has_secure_password

  belongs_to :client, optional: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password_confirmation, presence: true, unless: proc { |u| u.password.blank? }

  scope :active, -> { where active: true }

  def self.from_token_payload(payload)
    # raise when not found
    if !payload['aud'] || !payload['aud'].include?('backend')
      raise Knock.not_found_exception_class_name
    end

    User.active.find(payload['sub'])
  end

  def to_token_payload
    { sub: id, aud: [:backend] }
  end

  def admin?
    client_id.blank?
  end
end

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  email           :string
#  name            :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :integer
#
# Indexes
#
#  index_users_on_client_id  (client_id)
#  index_users_on_email      (email) UNIQUE
#

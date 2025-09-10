class Customer < ApplicationRecord
  validates :customer_id, presence: true

  scope :active, -> { where("lower(status) = 'active'") }

  scope :name_like, lambda { |name|
    query = "#{Customer.arel_table.name}.first_name ILIKE :name OR "
    query += "#{Customer.arel_table.name}.last_name ILIKE :name"

    where(query, name: "%#{name}%")
  }
  scope :email_equal, ->(email) { where('lower(email) = ?', email.downcase) }

  belongs_to :store

  def to_peak_customer
    self.class.to_peak_customer(self)
  end

  def self.to_peak_customer(customer)
    customer.slice(
      :status, :customer_id,
      :first_name, :last_name,
      :gender, :birthday,
      :email, :phone, :drivers_license,
      :notes,
      :last_modified_date_utc
    )
  end
end

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: customers
#
#  id                     :bigint           not null, primary key
#  birthday               :string
#  drivers_license        :string
#  email                  :string
#  first_name             :string
#  gender                 :string
#  last_modified_date_utc :string
#  last_name              :string
#  notes                  :string
#  phone                  :string
#  status                 :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  customer_id            :string
#  external_account_id    :string
#  store_id               :integer
#
# Indexes
#
#  idx_customer_phone                      (replace(replace(replace(replace((phone)::text, '-'::text, ''::text), ' '::text, ''::text), '('::text, ''::text), ')'::text, ''::text))
#  index_customers_on_lowercase_email      (lower((email)::text))
#  index_customers_on_store_id_and_status  (store_id, lower((status)::text))
#

class CustomerSync < ApplicationRecord
  enum status: { pending: 0, in_progress: 1, failed: 2, finished: 3 }

  belongs_to :store

  def from_last_modified_date
    CustomerSync.finished.where(store: store).where(external_account_id: store.api_key).last&.created_at
  end

  def do_process
    in_progress!
    customers = api_client.customers(from_last_modified_date)
    customers = parse_customers(customers)
    customers.each do |api_customer|
      init_customer_attributes = {
        customer_id: api_customer[:customer_id],
        store_id: store_id,
        external_account_id: store.api_key
      }
      customer = Customer.find_or_initialize_by(init_customer_attributes)
      customer.attributes = api_customer
      customer.save!
    rescue StandardError => e
      Airbrake.notify(e, params: { customer_sync: id }) unless @fail
      @fail = true
    end

    @fail ? failed! : finished!
  rescue StandardError => e
    Airbrake.notify(e, params: { customer_sync: id })
    failed!
  end

  def parse_customers(customers)
    customers.map do |customer|
      first_name, last_name = customer[:name].to_s.split(' ', 2)

      {
        customer_id: customer[:customerId],
        birthday: customer[:dateOfBirth],
        drivers_license: nil,
        email: customer[:emailAddress],
        first_name: first_name,
        last_name: last_name,
        gender: nil,
        notes: nil,
        phone: customer[:phone],
        status: customer[:status]
      }
    end
  end

  def api_client
    @api_client ||= Leaflogix::ApiClient.new(store.leaflogix_api_config)
  end
end

# == Schema Information
#
# Table name: customer_syncs
#
#  id                  :bigint           not null, primary key
#  status              :integer          default("pending")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  external_account_id :string
#  store_id            :bigint
#

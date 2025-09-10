class Webhooks::Treez::Customer < Webhooks::Treez::Base
  def parse
    {
      customer_id: payload['customer_id'],
      birthday: payload['birthday'],
      drivers_license: drivers_license,
      email: payload['email'],
      first_name: payload['first_name'],
      last_name: payload['last_name'],
      gender: payload['gender'],
      notes: notes,
      phone: payload['phone'],
      status: payload['status']
    }
  end

  private

  def drivers_license
    payload['drivers_license'] == 'N/A' ? nil : payload['drivers_license']
  end

  def notes
    payload['notes'] == 'N/A' ? nil : payload['notes']
  end

end

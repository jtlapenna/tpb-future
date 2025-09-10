class Webhooks::Treez::CustomerOrder < Webhooks::Treez::Base
  def parse
    {
      order_id: payload['ticket_id'],
      customer_id: payload['customer_id']
    }
  end
end

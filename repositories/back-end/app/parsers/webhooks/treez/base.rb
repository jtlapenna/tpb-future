class Webhooks::Treez::Base
  attr_reader :store, :payload

  def initialize(store, payload)
    @store = store
    @payload = payload
  end
end

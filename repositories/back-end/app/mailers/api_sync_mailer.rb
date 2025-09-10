class ApiSyncMailer < ApplicationMailer
  layout 'mailer'

  def sync_error(store_id, errors: [], exception: nil)
    @store = Store.find(store_id)
    @errors = errors
    @expception = exception

    mail to: ENV['API_ERRORS_EMAIL_TO'], subject: "Store sync error (#{@store.name})"
  end
end

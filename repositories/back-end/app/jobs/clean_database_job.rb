class CleanDatabaseJob < ApplicationJob
  queue_as :clean_database
  unique :until_executed

  def perform()
    ActiveRecord::Base.connection.execute("TRUNCATE versions")
    ActiveRecord::Base.connection.execute("TRUNCATE store_sync_items")
    ActiveRecord::Base.connection.execute("TRUNCATE store_syncs CASCADE")
    ActiveRecord::Base.connection.execute("TRUNCATE customer_syncs")
  end
end

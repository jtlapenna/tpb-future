class DeleteScheduledCatalogSyncAndScheduleStoreSync < ActiveRecord::Migration[5.2]
  def up
    Sidekiq::Cron::Job.destroy_all!

    Store.find_each do |store|
      store.send :schedule_sync
    end
  end
end

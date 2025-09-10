class AssignEnabledShareEmailProductToStore < ActiveRecord::Migration[5.2]
  def up
    execute(
      <<-SQL
        UPDATE stores
        SET enabled_share_email_product = (
          SELECT enabled_share_email_product FROM catalogs
          WHERE catalogs.store_id = stores.id
          LIMIT 1
        )
      SQL
    )
  end
end

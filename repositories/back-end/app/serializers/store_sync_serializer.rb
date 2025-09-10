class StoreSyncSerializer < ActiveModel::Serializer
  attributes :id

  has_many :store_sync_items
end

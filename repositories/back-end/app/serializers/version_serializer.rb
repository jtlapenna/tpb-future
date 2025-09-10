class VersionSerializer < ActiveModel::Serializer
    attributes :created_at, :item_type, :item_id
    attribute :user do 
        User.find_by(id: @object.whodunnit)&.name
    end
    attribute :change do
        @object.changeset
    end
end
  
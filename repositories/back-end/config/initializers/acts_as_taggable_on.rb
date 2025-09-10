ActsAsTaggableOn::Tag.class_eval do
  scope :name_like, lambda { |name|
    where('tags.name ILIKE :name', name: "%#{name}%")
  }

  scope :for_model, lambda { |model|
    joins(:taggings)
      .joins(
        "INNER JOIN #{model.table_name} ON #{model.table_name}.id = taggings.taggable_id \
        AND taggings.taggable_type = '#{model.name}'"
      )
  }

  scope :for_object, lambda { |object|
    joins(:taggings)
      .where(taggings: { taggable_id: object.id, taggable_type: object.class.name })
  }

  scope :for_objects, lambda { |objects|
    return unless objects.all? { |object| object.class == objects.first.class }

    joins(:taggings)
      .where(taggings: { taggable_id: objects.map(&:id), taggable_type: objects.first.class.name })
  }

  def self.union_scope(*scopes)
    id_column = "#{table_name}.#{primary_key}"
    sub_query = scopes.map { |s| s.select(id_column).to_sql }.join(' UNION ')
    where "#{id_column} IN (#{sub_query})"
  end
end

# == Schema Information
#
# Table name: tags
#
#  id              :integer          not null, primary key
#  taggings_count  :integer          default(TRUE)
#  name            :string
#

module UnionScope
  extend ActiveSupport::Concern

  class_methods do
    def union_scope(*scopes)
      id_column = "#{table_name}.#{primary_key}"
      sub_query = scopes.map { |s| "(#{s.select(id_column).to_sql})" }.join(' UNION ')
      where "#{id_column} IN (#{sub_query})"
    end
  end
end

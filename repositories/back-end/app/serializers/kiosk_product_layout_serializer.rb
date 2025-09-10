class KioskProductLayoutSerializer < ActiveModel::Serializer
  attribute :stylesheet do
    @object.stylesheet
  end

  has_many :values do
    @object.product_layout_values
  end
end

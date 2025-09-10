module ExternalModel
  extend ActiveSupport::Concern
  include ActiveModel::Model
  include ActiveModel::Serialization

  protected

  # Override active_model::attributes_assignment method.
  # Don't raise error for unknown attributes
  #
  # (See https://github.com/rails/rails/blob/v5.2.0/activemodel/lib/active_model/attribute_assignment.rb#L48)
  def _assign_attribute(k, v)
    setter = :"#{k}="

    # Ignore unknown attributes
    public_send(setter, v) if respond_to?(setter)
  end
end

require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = [:open_api]
  config.request_body_formatter = :json
  config.configurations_dir = Rails.root.join('docs/configurations/api')
  config.docs_dir = Rails.root.join('docs/api')
end

def sortable_api_parameters
  parameter :sort_by, type: :string, default: 'id'
  parameter :sort_direction, type: :string, enum: %w[asc desc], default: 'desc', with_example: true
end

def pageable_api_parameters
  parameter :page, type: :integer, default: 1, with_example: true
  parameter :per_page, type: :integer, default: 10, with_example: true
end

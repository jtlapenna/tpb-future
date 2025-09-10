require 'faker'
require 'factory_bot'
require 'webmock/rspec'
require 'paper_trail/frameworks/rspec'
require 'csv'
require 'simplecov'
require 'rspec_api_documentation'

ENV['BUCKET_NAME'] = 'test-images'
ENV['BUCKET_REGION'] = 'sa-east-1'

# This needs to be at the very top, before any other code is loaded
if ENV['COVERAGE']
  SimpleCov.start 'rails' do
    enable_coverage :branch
    enable_coverage_for_eval
    track_files "app/**/*.rb"
    track_files "lib/**/*.rb"
    
    add_filter %r{^/spec/}
    add_filter %r{^/config/}
    add_filter %r{^/db/}
    add_filter %r{^/vendor/}
    
    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Services', 'app/services'
    add_group 'Jobs', 'app/jobs'
    add_group 'Mailers', 'app/mailers'
    add_group 'Policies', 'app/policies'
    add_group 'Serializers', 'app/serializers'
    
    minimum_coverage 80
    minimum_coverage_by_file 70
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'

# Configure rspec_api_documentation
RspecApiDocumentation.configure do |config|
  config.format = :json
  config.docs_dir = Rails.root.join('doc', 'api')
  config.request_headers_to_include = ['Content-Type', 'Accept']
  config.response_headers_to_include = ['Content-Type']
  config.curl_host = nil
  config.api_name = 'API Documentation'
  config.keep_source_order = true
  config.disable_dsl_status!
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:context) do
    Faker::UniqueGenerator.clear
  end

  config.before do
    ENV['ALGOLIASEARCH_DISABLED'] = nil
    ENV['WILDCARD_VARIANT_ID'] = nil
    ENV['TWILIO_ACCOUNT_SID'] = nil
    ENV['TWILIO_API_KEY'] = nil
    ENV['TWILIO_API_SECRET'] = nil
    ENV['TWILIO_NUMBER_FROM'] = nil
    ENV['SMS_DELIVERY_METHOD'] = nil
    ENV['FLOWHUB_PREROLL_IMAGE_URL'] = nil
    ENV['STORE_SYNC_SKIP_SERVICE_UNAVAILABLE_NOTIFICATION'] = nil
  end

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

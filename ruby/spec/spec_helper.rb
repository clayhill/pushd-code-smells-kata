require 'webmock/rspec'
require 'timeout'

%w[lib spec].each { |folder| $LOAD_PATH << File.join(File.dirname(__FILE__), '..', folder) }
Dir['./spec/support/*.rb'].each { |support_helper| require support_helper }

RSpec.configure do |config|
  config.include AsyncHelper

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

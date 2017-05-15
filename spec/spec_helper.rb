require 'bundler/setup'
require 'postshift'

RSpec.configure do |config|
  TEST_ROOT = File.expand_path(File.dirname(__FILE__))

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

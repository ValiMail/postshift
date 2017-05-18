require 'bundler/setup'
require 'postshift'
require 'factory_girl'
require 'database_cleaner'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

  config.include FactoryGirl::Syntax::Methods
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    FactoryGirl.find_definitions
    DatabaseCleaner.strategy = :deletion
  end

  config.around(:each) do |example|
    example.run
    DatabaseCleaner.clean
  end
end

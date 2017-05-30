require 'spec_helper'
require 'factory_girl'
require 'database_cleaner'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    ARTest.connect
    FactoryGirl.find_definitions
    DatabaseCleaner.strategy = :deletion
  end

  config.around(:each) do |example|
    example.run
    DatabaseCleaner.clean
  end
end

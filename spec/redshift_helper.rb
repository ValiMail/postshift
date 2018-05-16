require 'spec_helper'
require 'factory_bot'
require 'database_cleaner'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    ARTest.connect
    FactoryBot.find_definitions
    DatabaseCleaner.strategy = :deletion
  end

  config.around(:each) do |example|
    example.run
    DatabaseCleaner.clean
  end
end

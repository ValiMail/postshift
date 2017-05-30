require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'active_record'
require_relative 'spec/support/config'
require_relative 'spec/support/connection'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :spec do
  include ActiveRecord::Tasks

  desc 'Run isolated non-Redshift reliant code examples'
  RSpec::Core::RakeTask.new(:isolated) do |t|
    t.pattern = 'spec/lib/**/*_spec.rb'
  end

  desc 'Run Redshift reliant code examples'
  RSpec::Core::RakeTask.new(:redshift) do |t|
    t.pattern = 'spec/redshift/**/*_spec.rb'
  end

  task :environment do
    ARTest.connect
    # DatabaseTasks.current_config = ARTest.config
    DatabaseTasks.database_configuration = ARTest.config
    DatabaseTasks.db_dir = File.expand_path('../spec/db', __FILE__)
    DatabaseTasks.env = 'test'
    DatabaseTasks.migrations_paths = File.join(DatabaseTasks.db_dir, 'migrate')
  end

  load 'active_record/railties/databases.rake'
end

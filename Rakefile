require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'active_record'
require_relative 'spec/support/config'
require_relative 'spec/support/connection'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :spec do
  include ActiveRecord::Tasks

  db_dir = File.expand_path('../spec/db', __FILE__)
  DatabaseTasks.migrations_paths = File.join(db_dir, 'migrate')

  task :environment do
    ARTest.connect
  end

  load 'active_record/railties/databases.rake'

  # task :environment do
  #   TEST_ROOT = 'spec'
  #   DATABASE_ENV = ENV['DATABASE_ENV'] || 'test'
  #   MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'spec/db/migrate'
  # end

  # task :configuration => :environment do
  #   @config = ARTest.config
  # end

  # task :configure_connection => :configuration do
  #   ARTest.connect
  #   ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
  # end

  # desc 'Create the database from config/database.yml for the current DATABASE_ENV'
  # task :create => :configure_connection do
  #   create_database @config
  # end

  # desc 'Drops the database for the current DATABASE_ENV'
  # task :drop => :configure_connection do
  #   ActiveRecord::Base.connection.drop_database @config['database']
  # end

  # desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  # task :migrate => :configure_connection do
  #   ActiveRecord::Migration.verbose = true
  #   ActiveRecord::Migrator.migrate MIGRATIONS_DIR, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  # end

  # desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  # task :rollback => :configure_connection do
  #   step = ENV['STEP'] ? ENV['STEP'].to_i : 1
  #   ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  # end

  # desc "Retrieves the current schema version number"
  # task :version => :configure_connection do
  #   puts "Current version: #{ActiveRecord::Migrator.current_version}"
  # end
end

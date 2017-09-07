namespace :postshift do
  namespace :schema do
    task connect: :environment do
      Postshift.adapter = ActiveRecord::Base.connection
    end

    desc 'Prepare Redshift instance for Schema Exports'
    task prepare: :connect do
      puts '*** Creating Admin Utilities ***'
      Postshift::Schema.create_admin_utilities!
      puts '*** Finished Creating Admin Utilities ***'
    end

    desc 'Creates a db/postshift_schema.sql file for Redshift databases'
    task dump: :connect do
      puts '*** Starting Postshift Schema Dump ***'
      Postshift::Schema.dump
      puts '*** Completed Postshift Schema Dump ***'
    end

    desc 'Restores db/postshift_schema.sql file to Redshift database'
    task restore: :connect do
      puts '*** Starting Postshift Schema Restore ***'
      Postshift::Schema.restore
      puts '*** Completed Postshift Schema Restore ***'
    end
  end
end

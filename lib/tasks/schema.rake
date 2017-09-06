namespace :postshift do
  namespace :schema do
    task connect: :environment do
      Postshift.adapter = ActiveRecord::Base.connection
    end

    desc 'Prepare Redshift instance for Schema Exports'
    task prepare: :connect do
      Postshift::Schema.create_view!
    end

    desc 'Creates a db/postshift_schema.sql file for Redshift databases'
    task dump: :connect do
      Postshift::Schema.dump
    end

    desc 'Restores db/postshift_schema.sql file to Redshift database'
    task restore: :connect do
      Postshift::Schema.restore
    end
  end
end

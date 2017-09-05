namespace :postshift do
  namespace :schema do
    desc 'Prepare Redshift instance for Schema Exports'
    task prepare: :environment do
      Postshift::Schema.create_view!
    end

    desc 'Creates a db/postshift_schema.sql file for Redshift databases'
    task dump: :environment do
      Postshift::Schema.dump
    end
  end
end

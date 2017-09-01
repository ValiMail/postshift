namespace :postshift do
  namespace :schema do
    desc 'Prepare Redshift instance for Schema Exports'
    task prepare: :environment do
      puts '*** Preparing Redshift for Schema Dump ***'
      Postshift::Schema.prepare!
    end
  end
end

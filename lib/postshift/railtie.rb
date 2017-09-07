class Postshift::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/schema.rake'
  end
end

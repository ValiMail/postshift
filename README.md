# Postshift

Amazon Redshift extension for ActiveRecord 5 (Rails 5) PostgreSQL adapter based off of the existing activerecord5-redshift-adapter.  This version has 3 primary goals:

1. Function as an extension of the PostgreSQL ActiveRecord adapter.  Overriding or extending as needed to properly account for the differences between PostgreSQL and Redshift.
2. Create a functioning test suite.
3. Operate within both ActiveRecord 5 and 5.1.

<https://github.com/ConsultingMD/activerecord5-redshift-adapter>

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postshift'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install postshift

In your Rails 5+ database.yml

```ruby
development:
  adapter: redshift
  host: your_cluster_name.at.redshift.amazonaws.com
  port: 5439
  database: your_db
  username: your_user
  password: your_password
  encoding: utf8
  pool: 3
  timeout: 5000
```

## Migrations

Postshift exposes Redshift table and column options within ActiveRecord migrations.

**DISTKEY & SORTKEY Table Configuration**

The DISTKEY and SORTKEY can be passed through the create_table syntax:

```
create_table 'example_table', distkey: 'name', sortkey: 'number' do |t|
	t.string :name
	t.integer :number
end
```

**Column Compression Encoding**

Redshift column compression encoding can be specified inline as an option within migrations:

```
create_table 'encoding_examples' do |t|
	t.integer :number, encoding: 'delta'
end
```

For more information on compression types:
<http://docs.aws.amazon.com/redshift/latest/dg/c_Compression_encodings.html>

## Schema Dump

Several Rake tasks exist to help with performing a schema dump of an existing Redshift database.  These utilize the [admin scripts provided by Amazon](https://github.com/awslabs/amazon-redshift-utils/tree/master/src/AdminViews).  All actions are performed using `ActiveRecord::Base.connection` by default.

These views **must** exist within the Redshift database under the **admin** schema prior to any _dump_ or _restore_ actions.  To generate, simple run:

```
rake postshift:schema:prepare
```

Once these views are in place, the _dump_ and _restore_ will be available and functional.


```
rake postshift:schema:dump
rake postshift:schema:restore
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

To run the full test suite, a functioning Redshift database instance is required.  Once provisioned, copy the example configuration and update with your connection information & run the spec migrations:

	cp spec/config.example.yml spec/config.yml

	rake spec:db:migrate

And finally, you can now run the entire test suite:

	rake spec
	
The spec structure is based on reliance of an available running Redshift instance.  These specs can be run separately:

```
rake spec:isolated	# Run isolated non-Redshift reliant code examples
rake spec:redshift	# Run Redshift reliant code examples
```

Additionally, there is multi-version test support through [Appraisal](https://github.com/thoughtbot/appraisal).

```
appraisal install
appraisal ar-5.0 rake spec
appraisal ar-5.1 rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ValiMail/postshift. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


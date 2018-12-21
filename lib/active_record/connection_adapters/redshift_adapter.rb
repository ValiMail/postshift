require 'active_support'
require 'active_support/core_ext/module/deprecation'

require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

require 'active_record/connection_adapters/redshift/column'
require 'active_record/connection_adapters/redshift/referential_integrity'
require 'active_record/connection_adapters/redshift/schema_definitions'
require 'active_record/connection_adapters/redshift/schema_dumper'
require 'active_record/connection_adapters/redshift/schema_statements'
require 'active_record/connection_adapters/redshift/type_metadata'

module ActiveRecord
  module ConnectionHandling # :nodoc
    RS_VALID_CONN_PARAMS = [:host, :hostaddr, :port, :dbname, :user, :password, :connect_timeout,
                            :client_encoding, :options, :application_name, :fallback_application_name,
                            :keepalives, :keepalives_idle, :keepalives_interval, :keepalives_count,
                            :tty, :sslmode, :requiressl, :sslcompression, :sslcert, :sslkey,
                            :sslrootcert, :sslcrl, :requirepeer, :krbsrvname, :gsslib, :service]

    # Establishes a connection to the database that's used by all Active Record objects
    def redshift_connection(config)
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params to PGconn.connect.
      conn_params.keep_if { |k, _| RS_VALID_CONN_PARAMS.include?(k) }

      # The postgres drivers don't allow the creation of an unconnected PGconn object,
      # so just pass a nil connection object for the time being.
      ConnectionAdapters::RedshiftAdapter.new(nil, logger, conn_params, config)
    end
  end

  module ConnectionAdapters
    class RedshiftAdapter < PostgreSQLAdapter
      ADAPTER_NAME = 'Redshift'.freeze

      NATIVE_DATABASE_TYPES = {
        primary_key: 'integer identity primary key',
        string:      { name: 'varchar' },
        text:        { name: 'varchar' },
        integer:     { name: 'integer' },
        float:       { name: 'float' },
        decimal:     { name: 'decimal' },
        datetime:    { name: 'timestamp' },
        time:        { name: 'timestamptz' },
        date:        { name: 'date' },
        bigint:      { name: 'bigint' },
        boolean:     { name: 'boolean' },
      }.freeze

      include Redshift::ColumnDumper
      include Redshift::ReferentialIntegrity
      include Redshift::SchemaStatements

      def schema_creation # :nodoc:
        Redshift::SchemaCreation.new self
      end

      def supports_index_sort_order?
        false
      end

      def supports_partial_index?
        false
      end

      def supports_expression_index?
        false
      end

      def supports_transaction_isolation?
        false
      end

      def supports_json?
        false
      end

      def supports_savepoints?
        false
      end

      def native_database_types #:nodoc:
        NATIVE_DATABASE_TYPES
      end

      def supports_extensions?
        false
      end

      def use_insert_returning?
        false
      end

      def supports_advisory_locks?
        false
      end

      def supports_ranges?
        false
      end

      def supports_materialized_views?
        false
      end

      def postgresql_version
        # Will pass all inernal version support checks
        Float::INFINITY
      end

      def reset!
        @lock.synchronize do
          clear_cache!
          reset_transaction
          unless @connection.transaction_status == ::PG::PQTRANS_IDLE
            @connection.query "ROLLBACK"
          end
          configure_connection
        end
      end

      def extension_enabled?(name)
        return false unless supports_extensions?
        super
      end

      def extensions
        return [] unless supports_extensions?
        super
      end

    private

      # Copied from PostgreSQL with minor registration changes.  If broken out, could override segments, etc
      def initialize_type_map(m = type_map) # :nodoc:
        register_class_with_limit m, 'int2', Type::Integer
        register_class_with_limit m, 'int4', Type::Integer
        register_class_with_limit m, 'int8', Type::Integer
        m.alias_type 'oid', 'int2'
        m.register_type 'float4', Type::Float.new
        m.alias_type 'float8', 'float4'
        m.register_type 'text', Type::Text.new
        register_class_with_limit m, 'varchar', Type::String
        m.alias_type 'char', 'varchar'
        m.alias_type 'name', 'varchar'
        m.alias_type 'bpchar', 'varchar'
        m.register_type 'bool', Type::Boolean.new
        m.alias_type 'timestamptz', 'timestamp'
        m.register_type 'date', Type::Date.new

        m.register_type 'timestamp' do |_, _, sql_type|
          precision = extract_precision(sql_type)
          OID::DateTime.new(precision: precision)
        end

        m.register_type 'numeric' do |_, fmod, sql_type|
          precision = extract_precision(sql_type)
          scale = extract_scale(sql_type)

          # The type for the numeric depends on the width of the field,
          # so we'll do something special here.
          #
          # When dealing with decimal columns:
          #
          # places after decimal  = fmod - 4 & 0xffff
          # places before decimal = (fmod - 4) >> 16 & 0xffff
          if fmod && (fmod - 4 & 0xffff).zero?
            # Remove this class, and the second argument to lookups on PG
            Type::DecimalWithoutScale.new(precision: precision)
          else
            OID::Decimal.new(precision: precision, scale: scale)
          end
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def configure_connection
        if @config[:encoding]
          @connection.set_client_encoding(@config[:encoding])
        end
        self.schema_search_path = @config[:schema_search_path] || @config[:schema_order]

        # SET statements from :variables config hash
        # http://www.postgresql.org/docs/8.3/static/sql-set.html
        variables = @config[:variables] || {}
        variables.map do |k, v|
          if v == ':default' || v == :default
            # Sets the value to the global or compile default
            execute("SET SESSION #{k} TO DEFAULT", 'SCHEMA')
          elsif !v.nil?
            execute("SET SESSION #{k} TO #{quote(v)}", 'SCHEMA')
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Returns the list of a table's column names, data types, and default values.
      #
      # The underlying query is roughly:
      #  SELECT column.name, column.type, default.value
      #    FROM column LEFT JOIN default
      #      ON column.table_id = default.table_id
      #     AND column.num = default.column_num
      #   WHERE column.table_id = get_table_id('table_name')
      #     AND column.num > 0
      #     AND NOT column.is_dropped
      #   ORDER BY column.num
      #
      # If the table name is not prefixed with a schema, the database will
      # take the first match from the schema search path.
      #
      # Query implementation notes:
      #  - format_type includes the column size constraint, e.g. varchar(50)
      #  - ::regclass is a function that gives the id for a table name
      def column_definitions(table_name) # :nodoc:
        query(<<-end_sql, 'SCHEMA')
            SELECT a.attname, format_type(a.atttypid, a.atttypmod),
                   pg_get_expr(d.adbin, d.adrelid), a.attnotnull, a.atttypid, a.atttypmod,
                   format_encoding(a.attencodingtype::integer)
              FROM pg_attribute a LEFT JOIN pg_attrdef d
                ON a.attrelid = d.adrelid AND a.attnum = d.adnum
             WHERE a.attrelid = '#{quote_table_name(table_name)}'::regclass
               AND a.attnum > 0 AND NOT a.attisdropped
             ORDER BY a.attnum
        end_sql
      end

      def create_table_definition(*args) # :nodoc:
        Redshift::TableDefinition.new(*args)
      end
    end
  end
end

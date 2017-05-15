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
        time:        { name: 'time' },
        date:        { name: 'date' },
        bigint:      { name: 'bigint' },
        boolean:     { name: 'boolean' },
      }.freeze

      def supports_index_sort_order?
        false
      end

      def supports_partial_index?
        false
      end

      def supports_transaction_isolation?
        false
      end

      def supports_json?
        false
      end

      def supports_extensions?
        false
      end

      def supports_ranges?
        false
      end

      def supports_materialized_views?
        false
      end

      def use_insert_returning?
        false
      end

      def postgresql_version
        Float::INFINITY
      end

    private

      def initialize_type_map(m) # :nodoc:
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
        m.register_type 'time', Type::Time.new

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
            # FIXME: Remove this class, and the second argument to
            # lookups on PG
            Type::DecimalWithoutScale.new(precision: precision)
          else
            OID::Decimal.new(precision: precision, scale: scale)
          end
        end

        # load_additional_types(m)
      end

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
    end
  end
end

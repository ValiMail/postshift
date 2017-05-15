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
    class RedshiftAdapter < PostgresAdapter
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

    def postgresql_version
      99999999999999999999
    end
  end
end

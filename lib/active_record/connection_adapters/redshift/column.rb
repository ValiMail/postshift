module ActiveRecord
  module ConnectionAdapters
    class RedshiftColumn < PostgreSQLColumn #:nodoc:
      delegate :encoding, to: :sql_type_metadata
    end
  end
end

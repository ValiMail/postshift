module ActiveRecord
  module ConnectionAdapters
    module Redshift
      module ColumnDumper
        # Adds +:encoding+ option to the default set
        def prepare_column_options(column)
          super.tap do |spec|
            spec[:encoding] = "'#{column.sql_type_metadata.encoding}'" if column.sql_type_metadata.encoding.present?
          end
        end

        # Adds +:encoding+ as a valid migration key
        def migration_keys
          super + [:encoding]
        end
      end
    end
  end
end

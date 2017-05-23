module ActiveRecord
  module ConnectionAdapters
    module Redshift
      module ColumnDumper
        def column_spec_for_primary_key(column)
          super.tap do |spec|
            spec[:id] = ':primary_key' if column.sql_type == 'primary_key'
          end
        end

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

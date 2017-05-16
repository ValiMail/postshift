module ActiveRecord
  module ConnectionAdapters
    module Redshift
      module SchemaStatements
        # Create a new Redshift database. Options include <tt>:owner</tt> and <tt>:connection_limit</tt> 
        # Example:
        #   create_database config[:database], config
        #   create_database 'foo_development', encoding: 'unicode'
        def create_database(name, options = {})
          options = { encoding: 'utf8' }.merge!(options.symbolize_keys)

          option_string = options.inject("") do |memo, (key, value)|
            memo += case key
            when :owner
              " OWNER = \"#{value}\""
            when :connection_limit
              " CONNECTION LIMIT = #{value}"
            else
              '' 
            end
          end

          execute "CREATE DATABASE #{quote_table_name(name)}#{option_string}"
        end

        def index_name_exists?(*args)
          false
        end

        def indexes(*args)
          []
        end

        # Returns the list of all column definitions for a table.
        def columns(table_name)
          column_definitions(table_name.to_s).map do |column_name, type, default, notnull, oid, fmod|
            default_value = extract_value_from_default(default)
            type_metadata = fetch_type_metadata(column_name, type, oid, fmod)
            default_function = extract_default_function(default_value, default)
            new_column(column_name, default_value, type_metadata, notnull == 'f', table_name, default_function)
          end
        end        

        def new_column(name, default, sql_type_metadata = nil, null = true, table_name = nil, default_function = nil) # :nodoc:
          RedshiftColumn.new(name, default, sql_type_metadata, null, table_name, default_function)
        end

        def collation
        end

        def ctype
        end

        def set_pk_sequence!(*args) #:nodoc:
        end

        def reset_pk_sequence!(*args) #:nodoc:
        end

        def pk_and_sequence_for(*args) #:nodoc:
          [nil, nil]
        end

        # Returns just a table's primary key
        def primary_keys(table)
          pks = query(<<-end_sql, 'SCHEMA')
            SELECT DISTINCT attr.attname
            FROM pg_attribute attr
            INNER JOIN pg_depend dep ON attr.attrelid = dep.refobjid AND attr.attnum = dep.refobjsubid
            INNER JOIN pg_constraint cons ON attr.attrelid = cons.conrelid AND attr.attnum = any(cons.conkey)
            WHERE cons.contype = 'p'
              AND dep.refobjid = '#{quote_table_name(table)}'::regclass
          end_sql
          pks.present? ? pks[0] : pks
        end        
      end
    end
  end
end

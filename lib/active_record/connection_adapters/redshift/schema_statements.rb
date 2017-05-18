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

        # def index_name_exists?(*args)
        #   false
        # end

        # def indexes(*args)
        #   []
        # end

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

        # def collation
        # end

        # def ctype
        # end

        # def set_pk_sequence!(*args) #:nodoc:
        # end

        # def reset_pk_sequence!(*args) #:nodoc:
        # end

        # def pk_and_sequence_for(*args) #:nodoc:
        #   [nil, nil]
        # end

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

        # TODO: This entire method block for 't2.oid::regclass::text' to 't2.relname' 
        def foreign_keys(table_name)
          fk_info = select_all(<<-SQL.strip_heredoc, 'SCHEMA')
            SELECT t2.relname AS to_table, a1.attname AS column, a2.attname AS primary_key, c.conname AS name, c.confupdtype AS on_update, c.confdeltype AS on_delete
            FROM pg_constraint c
            JOIN pg_class t1 ON c.conrelid = t1.oid
            JOIN pg_class t2 ON c.confrelid = t2.oid
            JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
            JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
            JOIN pg_namespace t3 ON c.connamespace = t3.oid
            WHERE c.contype = 'f'
              AND t1.relname = #{quote(table_name)}
              AND t3.nspname = ANY (current_schemas(false))
            ORDER BY c.conname
          SQL

          fk_info.map do |row|
            options = {
              column: row['column'],
              name: row['name'],
              primary_key: row['primary_key']
            }

            options[:on_delete] = extract_foreign_key_action(row['on_delete'])
            options[:on_update] = extract_foreign_key_action(row['on_update'])

            ForeignKeyDefinition.new(table_name, row['to_table'], options)
          end
        end
      end
    end
  end
end

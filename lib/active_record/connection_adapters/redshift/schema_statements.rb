module ActiveRecord
  module ConnectionAdapters
    module Redshift
      class SchemaCreation < PostgreSQL::SchemaCreation
        private

        def add_column_options!(sql, options)
          sql = super
          if (encoding = encoding_option(options)).present?
            sql << " ENCODE #{encoding}"
          end
          sql
        end

        def encoding_option(options)
          if ActiveRecord.version < Gem::Version.new('5.1')
            options[:column].encoding
          else
            options[:encoding]
          end
        end
      end

      module SchemaStatements
        # Create a new Redshift database. Options include <tt>:owner</tt> and <tt>:connection_limit</tt> 
        # Example:
        #   create_database config[:database], config
        #   create_database 'foo_development', encoding: 'unicode'
        def create_database(name, options = {})
          options = { encoding: 'utf8' }.merge!(options.symbolize_keys)
          option_string = ''
          option_string += " OWNER = \"#{options[:owner]}\"" if options[:owner].present?
          option_string += " CONNECTION LIMIT = #{options[:connection_limit]}" if options[:connection_limit].present?

          execute "CREATE DATABASE #{quote_table_name(name)}#{option_string}"
        end
 
        def create_table(table_name, comment: nil, **options)
          options[:options] ||= ''
          options[:options] += "DISTKEY(#{options.delete(:distkey)}) " if options.key?(:distkey)
          options[:options] += "SORTKEY(#{options.delete(:sortkey)}) " if options.key?(:sortkey)
          super
        end

        def indexes(*)
          []
        end

        # Returns the list of all column definitions for a table.
        # rubocop:disable Metrics/ParameterLists
        def columns(table_name)
          column_definitions(table_name.to_s).map do |column_name, type, default, notnull, oid, fmod, encoding|
            default_value = extract_value_from_default(default)
            type = determine_primary_key_type_conversion(type, default)
            type_metadata = fetch_type_metadata(column_name, type, oid, fmod, encoding)
            default_function = extract_default_function(default_value, default)
            new_column(column_name, default_value, type_metadata, notnull == false, table_name, default_function)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        def determine_primary_key_type_conversion(type, default)
          return 'primary_key' if (type == 'integer' && default.to_s.starts_with?('"identity"'))
          type
        end

        # rubocop:disable Metrics/ParameterLists
        def new_column(name, default, sql_type_metadata = nil, null = true, table_name = nil, default_function = nil) # :nodoc:
          RedshiftColumn.new(name, default, sql_type_metadata, null, table_name, default_function)
        end
        # rubocop:enable Metrics/ParameterLists

        def table_options(table_name) # :nodoc:
          {}.tap do |options|
            if (distkey = table_distkey(table_name)).present?
              options[:distkey] = distkey
            end
            if (sortkey = table_sortkey(table_name)).present?
              options[:sortkey] = sortkey
            end
          end
        end

        def table_distkey(table_name) # :nodoc:
          select_value("SELECT \"column\" FROM pg_table_def WHERE tablename = #{quote(table_name)} AND distkey = true")
        end

        def table_sortkey(table_name) # :nodoc:
          columns = select_values("SELECT \"column\" FROM pg_table_def WHERE tablename = #{quote(table_name)} AND sortkey > 0 ORDER BY sortkey ASC")
          columns.present? ? columns.join(', ') : nil
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

        # This entire method block for 't2.oid::regclass::text' to 't2.relname'
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

        def fetch_type_metadata(column_name, sql_type, oid, fmod, encoding)
          cast_type = get_oid_type(oid, fmod, column_name, sql_type)
          simple_type = SqlTypeMetadata.new(
            sql_type: sql_type,
            type: cast_type.type,
            limit: cast_type.limit,
            precision: cast_type.precision,
            scale: cast_type.scale,
          )
          RedshiftSQLTypeMetadata.new(simple_type, oid: oid, fmod: fmod, encoding: encoding)
        end
      end
    end
  end
end

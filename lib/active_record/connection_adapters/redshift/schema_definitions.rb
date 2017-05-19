module ActiveRecord
  module ConnectionAdapters
    module Redshift
      class ColumnDefinition < Struct.new(:name, :type, :limit, :precision, :scale, :default, :null, :first, :after, :auto_increment, :primary_key, :collation, :sql_type, :comment, :encoding)
        attr_accessor :array

        def primary_key?
          primary_key || type.to_sym == :primary_key
        end
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        include ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods

        def new_column_definition(name, type, options) # :nodoc:
          column = super
          column.encoding = options[:encoding]
          column
        end

        private

        def create_column_definition(name, type)
          Redshift::ColumnDefinition.new name, type
        end
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    module Redshift
      # All this to add 'encoding' to Structure
      class ColumnDefinition < Struct.new(:name, :type, :limit, :precision, :scale, :default, :null, :first, :after, :auto_increment, :primary_key, :collation, :sql_type, :comment, :encoding)
        # From PostgreSQL to maintain compatability
        attr_accessor :array

        # From Abstract to maintain compatability
        def primary_key?
          primary_key || type.to_sym == :primary_key
        end
      end

      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        include ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods

        def new_column_definition(name, type, options) # :nodoc:
          super.tap do |column|
            column.encoding = options[:encoding]
          end
        end

        private

        def create_column_definition(name, type)
          ColumnDefinition.new name, type
        end
      end
    end
  end
end

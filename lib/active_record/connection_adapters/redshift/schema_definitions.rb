module ActiveRecord
  module ConnectionAdapters
    module Redshift
      if ActiveRecord.version < Gem::Version.new('5.1')
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

          def create_column_definition(name, type, options=nil)
            ColumnDefinition.new name, type, options
          end
        end
      else
        class TableDefinition < ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition
          def primary_key(name, type=:primary_key, **options)
            ints = %i(integer bigint)
            options[:auto_increment] ||= true if ints.include?(type) && !options.key?(:default)
            type = :primary_key if ints.include?(type) && options.delete(:auto_increment) == true
            super
          end
        end
      end
    end
  end
end

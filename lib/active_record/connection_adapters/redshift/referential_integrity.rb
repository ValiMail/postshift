module ActiveRecord
  module ConnectionAdapters
    module Redshift
      module ReferentialIntegrity # :nodoc:
        def disable_referential_integrity # :nodoc:
          yield
        end
      end
    end
  end
end

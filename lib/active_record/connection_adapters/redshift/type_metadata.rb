module ActiveRecord
  module ConnectionAdapters
    class RedshiftSQLTypeMetadata < PostgreSQLTypeMetadata
      attr_reader :encoding

      def initialize(type_metadata, oid: nil, fmod: nil, encoding: nil)
        super(type_metadata, oid: oid, fmod: fmod)
        @encoding = encoding unless encoding == 'none'
      end

      protected

      def attributes_for_hash
        super << encoding
      end
    end
  end
end

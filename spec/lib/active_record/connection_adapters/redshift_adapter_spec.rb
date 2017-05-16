require 'spec_helper'

RSpec.describe ActiveRecord::ConnectionAdapters::RedshiftAdapter, type: :model do
  describe 'Connection' do
    subject { ARTest.connect.connection }

    describe '#native_database_types' do
      it do
        expect(subject.native_database_types.keys).to eq \
          %i( primary_key string text integer float decimal datetime time date bigint boolean )
      end
    end

    describe 'SchemaStatements' do
      describe '#columns' do
        pending
      end

      describe '#new_column' do
        pending
      end

      describe '#primary_keys' do
        pending
      end
    end
  end

  describe 'Configuration Overrides' do
    subject { described_class.allocate }

    describe '#supports_index_sort_order?' do
      it { expect(subject).to_not be_supports_index_sort_order }
    end

    describe '#supports_partial_index?' do
      it { expect(subject).to_not be_supports_partial_index }
    end

    describe '#supports_supports_transaction_isolation?' do
      it { expect(subject).to_not be_supports_transaction_isolation }
    end

    describe '#supports_supports_transaction_isolation?' do
      it { expect(subject).to_not be_supports_transaction_isolation }
    end

    describe '#supports_json?' do
      it { expect(subject).to_not be_supports_json }
    end

    describe '#supports_extensions?' do
      it { expect(subject).to_not be_supports_extensions }
    end

    describe '#supports_ranges?' do
      it { expect(subject).to_not be_supports_ranges }
    end

    describe '#supports_materialized_views?' do
      it { expect(subject).to_not be_supports_materialized_views }
    end

    describe '#use_insert_returning?' do
      it { expect(subject).to_not be_use_insert_returning }
    end

    describe '#postgresql_version' do
      it { expect(subject.postgresql_version).to be Float::INFINITY }
    end

    describe 'SchemaStatements' do
      describe '#index_name_exists?' do
        it { expect(subject.index_name_exists?('any', 'thing', 'here')).to be false }
      end

      describe '#indexes' do
        it { expect(subject.indexes('this-table')).to eq [] }
      end

      describe '#collation' do
        it { expect(subject.collation).to be_nil }
      end

      describe '#ctype' do
        it { expect(subject.ctype).to be_nil }
      end

      describe '#set_pk_sequence!' do
        it { expect(subject.set_pk_sequence!('the-table', 'the-value')).to be_nil }
      end

      describe '#reset_pk_sequence!' do
        it { expect(subject.reset_pk_sequence!('the-table')).to be_nil }
      end

      describe '#pk_and_sequence_for' do
        it { expect(subject.pk_and_sequence_for('a-table')).to eq [nil, nil] }
      end
    end
  end
end

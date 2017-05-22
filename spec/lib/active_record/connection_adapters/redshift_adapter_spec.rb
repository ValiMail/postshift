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
      describe '#create_database' do
        pending 'Ensure full method is needed.  Possibly reduce options and call super?'
      end

      describe '#create_table' do
        pending
      end

      describe '#columns' do
        pending
      end

      describe '#new_column' do
        pending
      end

      describe '#table_options' do
        context 'w/ table has dist & sort keys' do
          it 'returns an empty hash' do
            expect(subject.table_options('table_options')).to \
              eq({ distkey: 'name', sortkey: 'number' })
          end
        end

        context 'w/ table has no additional settings' do
          it 'returns an empty hash' do
            expect(subject.table_options('column_options')).to eq({})
          end
        end
      end

      describe '#table_distkey' do
        context 'w/ exists on table' do
          it 'returns column name' do
            expect(subject.table_distkey('table_options')).to eq 'name'
          end
        end

        context 'w/ does not exist on table' do
          it 'returns nil' do
            expect(subject.table_distkey('column_options')).to be_nil
          end
        end
      end

      describe '#table_sortkey' do
        context 'w/ exists on table' do
          it 'returns column name' do
            expect(subject.table_sortkey('table_options')).to eq 'number'
          end
        end

        context 'w/ does not exist on table' do
          it 'returns nil' do
            expect(subject.table_sortkey('column_options')).to be_nil
          end
        end
      end

      describe '#fetch_type_metadata' do
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

    describe '#supports_expression_index?' do
      it { expect(subject).to_not be_supports_expression_index }
    end

    describe '#supports_supports_transaction_isolation?' do
      it { expect(subject).to_not be_supports_transaction_isolation }
    end

    describe '#supports_json?' do
      it { expect(subject).to_not be_supports_json }
    end

    describe '#supports_savepoints?' do
      it { expect(subject).to_not be_supports_savepoints }
    end

    describe '#supports_extensions?' do
      it { expect(subject).to_not be_supports_extensions }
    end

    describe '#supports_advisory_locks?' do
      it { expect(subject).to_not be_supports_advisory_locks }
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

    describe 'ReferentialIntegrity' do
      describe '#disable_referential_integrity' do
        it 'simply yields and returns given block' do
          # expect(subject.disable_referential_integrity { 'is neat' }).to eq 'is neat' }
        end
      end
    end

    describe 'SchemaStatements' do
      describe '#indexes' do
        it { expect(subject.indexes('this-table')).to eq [] }
      end
    end
  end
end

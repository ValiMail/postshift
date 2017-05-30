require 'spec_helper'

RSpec.describe ActiveRecord::ConnectionAdapters::RedshiftAdapter, type: :model do
  subject { described_class.allocate }

  describe 'Configuration Overrides' do
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

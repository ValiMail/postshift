require 'redshift_helper'

RSpec.describe ActiveRecord::ConnectionAdapters::RedshiftAdapter, type: :model do
  subject { ARTest.connect.connection }

  describe '#create_database' do
    pending 'Ensure full method is needed.  Possibly reduce options and call super?'
  end

  describe '#create_table' do
    pending
  end

  describe '#new_column' do
    let(:column) { subject.new_column('test', 'default', 'the-data', false, 'testing') }

    it { expect(column).to be_a ActiveRecord::ConnectionAdapters::RedshiftColumn }
    it { expect(column.name).to eq 'test' }
    it { expect(column.table_name).to eq 'testing' }
    it { expect(column.sql_type_metadata).to eq 'the-data' }
    it { expect(column.null).to be false }
    it { expect(column.default).to eq 'default' }
  end

  describe '#table_options' do
    context 'w/ table has dist & sort keys' do
      it 'returns an empty hash' do
        expect(subject.table_options('table_options')).to \
          eq(distkey: 'name', sortkey: 'number')
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

    context 'w/ multiple exist on table' do
      it 'returns column names in correct order' do
        expect(subject.table_sortkey('table_options_multi_sorts')).to eq 'number1, number2, number3'
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

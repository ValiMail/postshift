require 'spec_helper'

class TableOption < ActiveRecord::Base
end

RSpec.describe TableOption, type: :model do
  before  { ARTest.connect }
  let(:columns_sql) { "SELECT \"column\", encoding, distkey, sortkey FROM pg_table_def WHERE tablename = '#{described_class.table_name}';" }
  let(:columns) { described_class.connection.query(columns_sql) }

  describe '"name" column"' do
    subject { columns.detect { |r| r.first == 'name' } }

    it 'has "lzo" encoding' do
      expect(subject[1]).to eq 'lzo'
    end

    it 'is the distkey' do
      expect(subject[2]).to be true
    end

    it 'is not a sortkey' do
      expect(subject[3]).to eq 0
    end
  end

  describe '"number" column"' do
    subject { columns.detect { |r| r.first == 'number' } }

    it 'has "none" encoding' do
      expect(subject[1]).to eq 'none'
    end

    it 'is not the distkey' do
      expect(subject[2]).to be false
    end

    it 'is a sortkey' do
      expect(subject[3]).to eq 1
    end
  end
end

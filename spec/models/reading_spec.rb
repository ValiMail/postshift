require 'spec_helper'

class Reading < ActiveRecord::Base
  self.table_name = :dmarc_report_records
end

RSpec.describe Reading, type: :model do
  before { ARTest.connect }

  describe 'connection' do
    it 'is using RedshiftAdapter' do
      expect(Reading.connection).to be_a ActiveRecord::ConnectionAdapters::RedshiftAdapter
    end

    it 'reads column names' do
      raise Reading.column_names.inspect
    end
  end

  describe 'data' do
    subject { described_class.first }

    describe 'Integer' do
      it { expect(subject.record_num).to be_a Integer }
    end
  end
end

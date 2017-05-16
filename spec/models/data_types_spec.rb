require 'spec_helper'

class DataType < ActiveRecord::Base
end

RSpec.describe DataType, type: :model do
  before { ARTest.connect }

  describe 'connection' do
    it 'is using RedshiftAdapter' do
      expect(described_class.connection).to be_a ActiveRecord::ConnectionAdapters::RedshiftAdapter
    end

    it 'reads column names' do
      raise described_class.column_names.inspect
    end
  end

  describe 'data' do
    subject { described_class.first }

    describe 'Integer' do
      it { expect(subject.record_num).to be_a Integer }
    end

    describe 'String' do
      it { expect(subject.ptr_name).to be_a String }
    end

    # describe 'Boolean' do
    #   it { expect(subject.dmarc_spf_pass).to be_a TrueClass }
    #   it { expect(subject.dmarc_dkim_pass).to be_a TrueClass }
    # end
  end
end

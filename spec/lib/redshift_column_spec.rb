require 'spec_helper'

RSpec.describe ActiveRecord::ConnectionAdapters::RedshiftColumn do
  describe '.new' do
    context 'w/ minimal arguments' do
      subject { described_class.new('test', 'something', 'string') }

      it { is_expected.to be_a described_class }

      context '#name' do
        it { expect(subject.name).to eq 'test' }
      end

      context '#table_name' do
        it { expect(subject.table_name).to be_nil }
      end

      context '#sql_type_metadata' do
        it { expect(subject.sql_type_metadata).to eq 'string' }
      end

      context '#null' do
        it { expect(subject.null).to be true }
      end

      context '#default' do
        it { expect(subject.default).to eq 'something' }
      end

      context '#default_function' do
        it { expect(subject.default_function).to be_nil }
      end

      context '#collation' do
        it { expect(subject.collation).to be_nil }
      end

      context '#comment' do
        it { expect(subject.comment).to be_nil }
      end
    end

    context 'w/ all arguments' do
      subject { described_class.new('test', 'something', 'string', false, 'test_table', 'cool') }

      it { is_expected.to be_a described_class }

      context '#name' do
        it { expect(subject.name).to eq 'test' }
      end

      context '#table_name' do
        it { expect(subject.table_name).to eq 'test_table' }
      end

      context '#sql_type_metadata' do
        it { expect(subject.sql_type_metadata).to eq 'string' }
      end

      context '#null' do
        it { expect(subject.null).to be false }
      end

      context '#default' do
        it { expect(subject.default).to eq 'something' }
      end

      context '#default_function' do
        it { expect(subject.default_function).to eq 'cool' }
      end

      context '#collation' do
        it { expect(subject.collation).to be_nil }
      end

      context '#comment' do
        it { expect(subject.comment).to be_nil }
      end
    end
  end
end

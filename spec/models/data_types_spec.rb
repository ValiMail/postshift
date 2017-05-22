require 'spec_helper'

class DataType < ActiveRecord::Base
end

FactoryGirl.define do
  factory :data_type do
    a_required_string   'is-present'
    a_required_boolean  true
  end
end

RSpec.describe DataType, type: :model do
  before { ARTest.connect }

  describe 'connection' do
    it 'is using RedshiftAdapter' do
      expect(described_class.connection).to be_a ActiveRecord::ConnectionAdapters::RedshiftAdapter
    end

    describe '#column_names' do
      it 'returns array of names' do
        expect(described_class.column_names).to eq \
          %w( id a_string a_small_string a_required_string a_text
              an_integer a_small_integer a_bigint a_decimal a_non_decimal a_large_decimal a_float
              a_datetime a_time a_date
              a_boolean a_required_boolean a_true_boolean a_false_boolean )
      end
    end

    describe '#columns' do
      subject { described_class.columns }

      it 'is a collection of RedshiftColumns' do
        subject.each do |col|
          expect(col).to be_a ActiveRecord::ConnectionAdapters::RedshiftColumn
        end
      end
    end
  end

  describe 'data' do
    subject { described_class.last }

    describe '#id' do
      before  { create(:data_type) }
      it      { expect(subject.id).to be_a Integer }
    end

    describe '#a_string' do
      before  { create(:data_type, a_string: 'is a wonderful thing') }
      it      { expect(subject.a_string).to be_a String }
    end

    describe '#a_small_string' do
      context 'w/ within data limit' do
        before  { create(:data_type, a_small_string: 'is') }
        it      { expect(subject.a_small_string).to be_a String }
      end

      context 'w/ outside data limit'do
        it 'raises an error' do
          expect { create(:data_type, a_small_string: 'not') }.to \
            raise_error { ActiveRecord::StatementInvalid.new }
        end
      end
    end

    describe '#a_required_string' do
      context 'w/ a value' do
        before  { create(:data_type, a_required_string: 'is given') }
        it      { expect(subject.a_required_string).to be_a String }
      end

      context 'w/o a value' do
        it 'raises an error' do
          expect { create(:data_type, a_reqiured_string: nil) }.to \
            raise_error { ActiveRecord::StatementInvalid.new }
        end
      end
    end

    describe '#a_text' do
      before  { create(:data_type, a_text: 'is a string') }
      it      { expect(subject.a_text).to be_a String }
    end

    describe '#an_integer' do
      before  { create(:data_type, an_integer: 1) }
      it      { expect(subject.an_integer).to be_a Integer }
    end

    describe '#a_small_integer' do
      before  { create(:data_type, a_small_integer: 1) }
      it      { expect(subject.a_small_integer).to be_a Integer }
    end

    describe '#a_bigint' do
      before  { create(:data_type, a_bigint: 1) }
      it      { expect(subject.a_bigint).to be_a Integer }
    end

    describe '#a_decimal' do
      before  { create(:data_type, a_decimal: 1.23) }
      it      { expect(subject.a_decimal).to be_a BigDecimal }
      it      { expect(subject.a_decimal).to eq 1.23 }
    end

    describe '#a_non_decimal' do
      before  { create(:data_type, a_non_decimal: 1.23) }
      it      { expect(subject.a_non_decimal).to be_a Integer }
      it      { expect(subject.a_non_decimal).to eq 1 }
    end

    describe '#a_large_decimal' do
      before  { create(:data_type, a_large_decimal: 1.23) }
      it      { expect(subject.a_large_decimal).to be_a BigDecimal }
      it      { expect(subject.a_large_decimal).to eq 1.2300 }
    end

    describe '#a_float' do
      before  { create(:data_type, a_float: 1.23) }
      it      { expect(subject.a_float).to be_a Float }
      it      { expect(subject.a_float).to eq 1.23 }
    end

    describe '#a_datetime' do
      before  { create(:data_type, a_datetime: DateTime.new(1981, 5, 8, 1, 2, 3)) }
      it      { expect(subject.a_datetime).to be_a Time }
      it      { expect(subject.a_datetime).to eq "1981-05-08 01:02:03 UTC" }
    end

    describe '#a_time' do
      before  { Time.zone = 'Pacific Time (US & Canada)' }
      before  { create(:data_type, a_time: Time.zone.local(1981, 5, 8, 3, 4, 5)) }
      it      { expect(subject.a_time).to be_a Time }
      it      { expect(subject.a_time).to eq "1981-05-08 10:04:05 UTC" }
      it      { expect(subject.a_time.localtime).to eq '1981-05-08 03:04:05 -0700' }
    end

    describe '#a_date' do
      let(:d) { Date.new(1981, 5, 8) }
      before  { create(:data_type, a_date: d) }
      it      { expect(subject.a_date).to be_a Date }
      it      { expect(subject.a_date).to eq d }
    end

    describe '#a_boolean' do
      before  { create(:data_type, a_boolean: nil) }
      it      { expect(subject.a_boolean).to be_a NilClass }
      it      { expect(subject.a_boolean).to be_nil }
    end

    describe '#a_required_boolean' do
      context 'w/ value' do
        before  { create(:data_type, a_required_boolean: true) }
        it      { expect(subject.a_required_boolean).to be_a TrueClass }
        it      { expect(subject.a_required_boolean).to be true }
      end

      context 'w/o value' do
        it 'raises an error' do
          expect { create(:data_type, a_reqiured_boolean: nil) }.to \
            raise_error { ActiveRecord::StatementInvalid.new }
        end
      end
    end

    describe '#a_true_boolean' do
      before  { create(:data_type, a_true_boolean: true) }
      it      { expect(subject.a_true_boolean).to be_a TrueClass }
      it      { expect(subject.a_true_boolean).to be true }
    end

    describe '#a_false_boolean' do
      before  { create(:data_type, a_false_boolean: false) }
      it      { expect(subject.a_false_boolean).to be_a FalseClass }
      it      { expect(subject.a_false_boolean).to be false }
    end
  end
end

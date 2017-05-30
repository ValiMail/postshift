require 'redshift_helper'

class QueryTest < ActiveRecord::Base
end

FactoryGirl.define do
  factory :query_test do
    name 'sur'
    number 1
    flag true
  end
end

RSpec.describe QueryTest, type: :model do
  describe '#count' do
    before { 5.times { create(:query_test) } }

    it 'can return that count' do
      expect(described_class.count).to eq 5
    end
  end

  describe '#where' do
    let!(:query1) { create(:query_test, name: 'bill') }
    let!(:query2) { create(:query_test, name: 'bob') }
    let!(:query3) { create(:query_test, name: 'Bob') }
    let!(:query4) { create(:query_test, name: 'Bob') }

    it 'filters correctly' do
      expect(described_class.where(name: 'bill').map(&:name)).to eq %w(bill)
    end

    it 'is case sensitive' do
      expect(described_class.where(name: 'bob').map(&:name)).to eq %w(bob)
      expect(described_class.where(name: 'Bob').map(&:name)).to eq %w(Bob Bob)
    end
  end

  describe '#sum' do
    let!(:query1) { create(:query_test, number: 1) }
    let!(:query2) { create(:query_test, number: 2) }
    let!(:query3) { create(:query_test, number: 3) }

    it 'creates from all records' do
      expect(described_class.sum(:number)).to eq 6
    end

    it 'creates from filtered records' do
      expect(described_class.where('number > 1').sum(:number)).to eq 5
    end
  end
end

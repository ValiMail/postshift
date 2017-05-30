require 'redshift_helper'

class Domestic < ActiveRecord::Base
end

class Foreign < ActiveRecord::Base
end

RSpec.describe Foreign, type: :model do
  context 'w/o any foreign keys' do
    subject { described_class.connection.foreign_keys('domestics') }

    it 'returns nothing' do
      expect(subject).to eq([])
    end
  end

  context 'w/ foreign key' do
    subject { described_class.connection.foreign_keys('foreigns') }

    it 'has one key' do
      expect(subject.size).to eq 1
    end

    it 'is from foreigns' do
      expect(subject.first.from_table).to eq 'foreigns'
    end

    it 'is to domestics' do
      expect(subject.first.to_table).to eq 'domestics'
    end

    it 'sets correct column' do
      expect(subject.first.options[:column]).to eq 'domestic_id'
    end
  end
end

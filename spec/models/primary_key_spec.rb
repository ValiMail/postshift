require 'spec_helper'

class PrimaryKeyTest < ActiveRecord::Base
end

class NoPrimaryKeyTest < ActiveRecord::Base
end

class CustomPrimaryKeyTest < ActiveRecord::Base
end

FactoryGirl.define do
  factory :primary_key_test do
  end
end

RSpec.describe PrimaryKeyTest, type: :model do
  before  { ARTest.connect }
  subject { create(:primary_key_test, name: 'pk-test') }
  before  { subject }

  describe '.primary_key' do
    it 'is the default (id) primary key' do
      expect(described_class.primary_key).to eq 'id'
    end
  end

  it 'does not set #id on creation' do
    expect(subject.id).to be_nil
  end

  it 'does have one set in DB' do
    expect(described_class.find_by(name: 'pk-test').id).to be_a Integer
  end
end

RSpec.describe NoPrimaryKeyTest, type: :model do
  before { ARTest.connect }

  describe '.primary_key' do
    it 'does not have one' do
      expect(described_class.primary_key).to be_nil
    end
  end
end

RSpec.describe CustomPrimaryKeyTest, type: :model do
  before { ARTest.connect }

  describe '.primary_key' do
    it 'identifies the custom column' do
      expect(described_class.primary_key).to eq 'for_me'
    end
  end
end

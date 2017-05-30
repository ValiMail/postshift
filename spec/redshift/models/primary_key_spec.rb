require 'redshift_helper'

class PrimaryKeyTest < ActiveRecord::Base
end

class NoPrimaryKeyTest < ActiveRecord::Base
end

class CustomPrimaryKeyTest < ActiveRecord::Base
end

class NonIncrementPrimaryKeyTest < ActiveRecord::Base
end

class StringPrimaryKeyTest < ActiveRecord::Base
end

FactoryGirl.define do
  factory :primary_key_test do
  end
end

RSpec.describe PrimaryKeyTest, type: :model do
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

  it 'has a type of integer' do
    expect(described_class.columns.first.sql_type_metadata.type).to eq :integer
  end

  it 'has a sql_type of primary_key' do
    expect(described_class.columns.first.sql_type_metadata.sql_type).to eq 'primary_key'
  end
end

RSpec.describe NoPrimaryKeyTest, type: :model do
  describe '.primary_key' do
    it 'does not have one' do
      expect(described_class.primary_key).to be_nil
    end
  end
end

RSpec.describe CustomPrimaryKeyTest, type: :model do
  describe '.primary_key' do
    it 'identifies the custom column' do
      expect(described_class.primary_key).to eq 'for_me'
    end
  end
end

RSpec.describe NonIncrementPrimaryKeyTest, type: :model do
  describe '.primary_key' do
    it 'identifies the column' do
      expect(described_class.primary_key).to eq 'id'
    end
  end

  it 'has a type of integer' do
    expect(described_class.columns.first.sql_type_metadata.type).to eq :integer
  end

  it 'has a sql_type of integer' do
    expect(described_class.columns.first.sql_type_metadata.sql_type).to eq 'integer'
  end
end

RSpec.describe StringPrimaryKeyTest, type: :model do
  describe '.primary_key' do
    it 'identifies the column' do
      expect(described_class.primary_key).to eq 'id'
    end
  end

  it 'has a type of string' do
    expect(described_class.columns.first.sql_type_metadata.type).to eq :string
  end

  it 'has a sql_type of string' do
    expect(described_class.columns.first.sql_type_metadata.sql_type).to start_with 'character varying'
  end
end

require 'spec_helper'

class PrimaryKeyTest < ActiveRecord::Base
end

FactoryGirl.define do
  factory :primary_key_test do
  end
end

RSpec.describe PrimaryKeyTest, type: :model do
  before  { ARTest.connect }
  subject { create(:primary_key_test, name: 'pk-test') }
  before  { subject }

  it 'does not set #id on creation' do
    expect(subject.id).to be_nil
  end

  it 'does have one set in DB' do
    expect(described_class.find_by(name: 'pk-test').id).to be_a Integer
  end
end

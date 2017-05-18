require 'spec_helper'

class Transactional < ActiveRecord::Base
end

FactoryGirl.define do
  factory :transactional do
    name 'me'
  end
end

RSpec.describe Transactional, type: :model do
  before { ARTest.connect }

  describe 'create' do
    describe 'failure' do
      let(:action) do
        described_class.transaction do
          create(:transactional)
          create(:transactional)
          raise ActiveRecord::Rollback
        end
      end

      it 'rolls back inserts' do
        expect { action }.to_not change(described_class, :count)
      end
    end

    describe 'successful' do
      let(:action) do
        described_class.transaction do
          create(:transactional)
          create(:transactional)
        end
      end

      it 'inserts' do
        expect { action }.to change(described_class, :count).by(2)
      end
    end
  end

  describe 'update' do
    let(:existing) { described_class.last }

    describe 'failure' do
      before { create(:transactional, name: 'original') }
      before do
        described_class.transaction do
          existing.update_attributes(name: 'new name')
          raise ActiveRecord::Rollback
        end
        existing.reload
      end

      it 'reverts to original name' do
        expect(existing.name).to eq 'original'
      end
    end

    describe 'successful' do
      before { create(:transactional, name: 'original') }
      before do
        described_class.transaction do
          existing.update_attributes(name: 'new name')
        end
        existing.reload
      end

      it 'updates to new name' do
        expect(existing.name).to eq 'new name'
      end
    end
  end

  describe 'deletion' do
    before do
      create(:transactional)
      create(:transactional)
      create(:transactional)
    end

    describe 'failure' do
      let(:action) do
        described_class.transaction do
          described_class.delete_all
          raise ActiveRecord::Rollback
        end
      end

      it 'rolls back deletes' do
        expect { action }.to_not change(described_class, :count)
      end
    end

    describe 'successful' do
      let(:action) do
        described_class.transaction do
          described_class.delete_all
        end
      end

      it 'rolls back deletes' do
        expect { action }.to change(described_class, :count).by(-3)
      end
    end
  end

end

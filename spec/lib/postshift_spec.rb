require 'spec_helper'

RSpec.describe Postshift do
  before(:each) do
    Postshift.adapter = nil
  end

  it 'has a version number' do
    expect(Postshift::VERSION).not_to be nil
  end

  describe '.root' do
    subject { described_class.root }

    it 'exposes current root directory of the gem' do
      is_expected.to end_with '/postshift'
    end
  end

  describe '.adapter=' do
    it 'sets the class variable' do
      expect do
        described_class.adapter = 'now set'
      end.to change(described_class, :adapter).from(nil).to('now set')
    end
  end

  describe '.adapter' do
    subject { described_class.adapter }

    context 'w/ not set' do
      it { is_expected.to be_nil }
    end

    context 'w/ set' do
      before { described_class.adapter = 'adapter' }
      it { is_expected.to eq 'adapter' }
    end
  end

  describe '.connection' do
    subject { described_class.connection }

    context 'w/ adapter is nil' do
      let(:adapter) { nil }
      before { allow(described_class).to receive(:adapter).and_return adapter }

      it { is_expected.to be_nil }
    end

    context 'w/ adapter does not support a :raw_connection' do
      let(:adapter) { double() }
      before { allow(described_class).to receive(:adapter).and_return adapter }

      it { is_expected.to be_nil }
    end

    context 'w/ :raw_connection is supported by the adapter' do
      let(:adapter) { double(raw_connection: 'is available') }
      before { allow(described_class).to receive(:adapter).and_return adapter }

      it { is_expected.to eq 'is available' }
    end
  end
end

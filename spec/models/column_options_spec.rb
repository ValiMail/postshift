require 'spec_helper'

class ColumnOption < ActiveRecord::Base
end

RSpec.describe ColumnOption, type: :model do
  before  { ARTest.connect }
  let(:columns_sql) { "SELECT encoding FROM pg_table_def WHERE tablename = '#{described_class.table_name}';" }
  let(:columns) { described_class.connection.query(columns_sql) }

  it 'can configure compression/encoding through migrations' do
    expect(columns[0].first).to eq 'delta'
  end

  it 'uses default compression if none specified' do
    expect(columns[1].first).to eq 'lzo'
  end
end

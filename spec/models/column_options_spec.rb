require 'spec_helper'

class ColumnOption < ActiveRecord::Base
end

RSpec.describe ColumnOption, type: :model do
  before  { ARTest.connect }
  let(:columns_sql) { "SELECT encoding FROM pg_table_def WHERE tablename = '#{described_class.table_name}';" }
  let(:columns) { described_class.connection.query(columns_sql) }
  subject { columns.first }

  it 'can configure compression/encoding through migrations' do
    expect(subject.first).to eq 'delta'
  end
end

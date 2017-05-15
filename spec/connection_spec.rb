require 'spec_helper'

class Mock
  include ActiveRecord::ConnectionHandling
  def logger
    nil
  end
end

RSpec.describe ActiveRecord::ConnectionHandling do
  it 'can connect to Redshift' do
    expect(ARTest.connect.connection).to be_a ActiveRecord::ConnectionAdapters::RedshiftAdapter
  end
end

require 'spec_helper'

class Domestic < ActiveRecord::Base
end

class Foreign < ActiveRecord::Base
end

RSpec.describe Foreign, type: :model do
  before { ARTest.connect }

  let(:sql) do
    <<-SQL
      SELECT  *
      FROM    pg_constraint
      WHERE	  conrelid = 'foreigns'::regclass
              AND confrelid = 'domestics'::regclass
    SQL
  end

  let(:constraint) { described_class.connection.query(sql).first }

  it 'has defined a foreign key contraint between the two tables' do
    expect(constraint.first).to start_with 'fk_rails'
  end

end

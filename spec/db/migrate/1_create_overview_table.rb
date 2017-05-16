class CreateOverviewTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'overviews' do |t|
      t.string  'a_string', limit: 256
    end
  end
end

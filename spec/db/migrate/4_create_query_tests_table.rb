class CreateQueryTestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'query_tests' do |t|
      t.string  :name
      t.integer :number
      t.boolean :flag
    end
  end
end

class CreatePrimaryKeyTestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'primary_key_tests' do |t|
      t.string :name
    end
  end
end

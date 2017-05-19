class CreatePrimaryKeyTestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'primary_key_tests' do |t|
      t.string :name
    end

    create_table 'no_primary_key_tests', id: false do |t|
      t.string :name
    end

    create_table 'custom_primary_key_tests', id: false do |t|
      t.primary_key :for_me
    end
  end
end

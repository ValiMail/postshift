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

    create_table 'non_increment_primary_key_tests', id: false do |t|
      t.integer :id, primary_key: true, auto_increment: false
      t.string :name
    end

    create_table 'string_primary_key_tests', id: false do |t|
      t.string :id, primary_key: true
    end
  end
end

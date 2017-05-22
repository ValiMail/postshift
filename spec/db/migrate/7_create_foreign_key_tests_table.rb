class CreateForeignKeyTestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'domestics' do |t|
    end

    create_table 'foreigns' do |t|
      t.integer :domestic_id
    end

    add_foreign_key :foreigns, :domestics
  end
end

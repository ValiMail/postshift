class CreateTableOptionsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'table_options', id: false, distkey: 'name', sortkey: 'number' do |t|
      t.string :name
      t.integer :number
    end

    create_table 'table_options_multi_sorts', id: false, sortkey: 'number1, number2, number3' do |t|
      t.integer :number3
      t.integer :number1
      t.integer :number2
    end
  end
end

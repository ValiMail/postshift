class CreateColumnOptionsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'column_options', id: false do |t|
      t.integer :number, encoding: 'delta'
    end
  end
end

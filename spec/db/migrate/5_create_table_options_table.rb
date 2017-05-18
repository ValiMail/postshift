class CreateTableOptionsTable < ActiveRecord::Migration[5.0]
  def change
    # options = 'DISTKEY(name) SORTKEY(number)'
    #
    create_table 'table_options', id: false, force: :cascade, distkey: 'name', sortkey: 'number' do |t|
      t.string :name
      t.integer :number
    end
  end
end

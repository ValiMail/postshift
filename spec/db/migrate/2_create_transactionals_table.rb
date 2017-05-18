class CreateTransactionalsTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'transactionals' do |t|
      t.string :name
    end
  end
end

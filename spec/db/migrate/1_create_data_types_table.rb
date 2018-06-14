class CreateDataTypesTable < ActiveRecord::Migration[5.0]
  def change
    create_table 'data_types' do |t|
      t.string    'a_string',           limit: 256
      t.string    'a_small_string',     limit: 2
      t.string    'a_required_string',  null: false

      t.text      'a_text'

      t.integer   'an_integer'
      t.integer   'a_small_integer', limit: 2
      t.bigint    'a_bigint'
      t.decimal   'a_decimal',          precision: 6, scale: 2
      t.decimal   'a_non_decimal',      precision: 6, scale: 0
      t.decimal   'a_large_decimal',    precision: 6, scale: 4
      t.float     'a_float'

      t.datetime  'a_datetime'
      t.time      'a_time'
      t.date      'a_date'

      t.boolean   'a_boolean'
      t.boolean   'a_required_boolean', null: false
      t.boolean   'a_true_boolean',     default: true
      t.boolean   'a_false_boolean',    default: false
    end
  end
end

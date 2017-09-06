class CreateTestDumpView < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW v_test_dump 
      AS SELECT 1 AS test;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW v_test_dump;
    SQL
  end
end



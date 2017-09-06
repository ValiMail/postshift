module Postshift
  module Schema
    FILENAME = 'postshift_schema.sql'.freeze

    def self.create_view!
      Postshift.connection.exec('CREATE SCHEMA IF NOT EXISTS admin')
      Postshift.connection.exec(generate_tbl_ddl_sql)
    end

    def self.remove_view!
      Postshift.connection.exec('DROP VIEW IF EXISTS admin.v_generate_tbl_ddl')
    end

    def self.view_exists?
      Postshift.connection.exec('SELECT \'admin.v_generate_tbl_ddl\'::regclass;')
      true
    rescue PG::UndefinedTable
      false
    end

    def self.generate_tbl_ddl_sql
      path = File.join(Postshift.root, 'lib', 'tasks', 'v_generate_tbl_ddl.sql')
      File.open(path).read
    end

    def self.dump
      File.open(output_location, 'w+') do |file|
        ddl_results.each_row do |row|
          file.puts(row)
        end
      end
    end

    def self.dump_sql
      if File.exist?(output_location)
        File.read(output_location)
      else
        puts 'Postshift Schema Dump file does not exist. Run task postshift:schema:dump'
        false
      end
    end

    def self.restore
      sql = dump_sql
      Postshift.connection.exec(sql) if sql.present?
    end

    def self.ddl_results
      Postshift.connection.exec(ddl_sql, schemas)
    end

    def self.output_location
      if defined?(Rails)
        File.join(Rails.root, 'db', FILENAME)
      else
        base_path = File.join(Postshift.root, 'tmp')
        Dir.mkdir(base_path) unless Dir.exist?(base_path)
        File.join(base_path, FILENAME)
      end
    end

    def self.schemas
      %w(public)
    end

    def self.ddl_sql
      <<-SQL
        SELECT  ddl
        FROM    admin.v_generate_tbl_ddl
        WHERE   schemaname IN ($1)
        ORDER BY tablename ASC, seq ASC
      SQL
    end
  end
end

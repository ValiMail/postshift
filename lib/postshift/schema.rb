module Postshift
  module Schema
    FILENAME = 'postshift_schema.sql'.freeze
    ADMIN_UTILITIES = %w(v_generate_tbl_ddl v_generate_view_ddl).freeze

    def self.ensure_admin_schema
      Postshift.connection.exec('CREATE SCHEMA IF NOT EXISTS admin')
    end

    def self.create_admin_utilities!
      ensure_admin_schema
      ADMIN_UTILITIES.each do |table_name|
        Postshift.connection.exec(generate_ddl_sql(table_name))
      end
    end

    def self.remove_admin_utilities!
      ensure_admin_schema
      ADMIN_UTILITIES.each do |table_name|
        Postshift.connection.exec("DROP VIEW IF EXISTS admin.#{table_name}")
      end
    end

    def self.admin_uilities_exists?
      ensure_admin_schema
      ADMIN_UTILITIES.each do |table_name|
        Postshift.connection.exec("SELECT 'admin.#{table_name}'::regclass;")
      end
      true
    rescue PG::UndefinedTable
      false
    end

    def self.generate_ddl_sql(table_name)
      path = File.join(Postshift.root, 'lib', 'tasks', "#{table_name}.sql")
      File.open(path).read
    end

    def self.dump
      File.open(output_location, 'w+') do |file|
        ddl_results(tbl_ddl_sql).each_row do |row|
          file.puts(row)
        end
        ddl_results(view_ddl_sql).each_row do |row|
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

    def self.ddl_results(ddl_sql)
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

    def self.tbl_ddl_sql
      <<-SQL
        SELECT  ddl
        FROM    admin.v_generate_tbl_ddl
        WHERE   schemaname IN ($1)
        ORDER BY tablename ASC, seq ASC
      SQL
    end

    def self.view_ddl_sql
      <<-SQL
        SELECT  ddl
        FROM    admin.v_generate_view_ddl
        WHERE   schemaname IN ($1)
        ORDER BY viewname ASC
      SQL
    end
  end
end

require 'redshift_helper'

RSpec.describe Postshift::Schema, type: :model do
  let(:base_path) { File.join(Postshift.root, 'tmp') }
  let(:clear_tmp) { FileUtils.remove_dir(base_path) }

  before { Postshift.adapter = ARTest.connect.connection }
  after(:each) { described_class.remove_admin_utilities! }

  describe '.ensure_admin_schema' do
    before { Postshift.connection.exec('DROP SCHEMA IF EXISTS admin CASCADE') }

    it 'generates admin schema if missing' do
      expect do
        described_class.ensure_admin_schema
      end.to change { Postshift.connection.exec('SELECT true FROM pg_namespace WHERE nspname = \'admin\';').count }.from(0).to(1)
    end
  end

  describe '.create_admin_utilities!' do
    subject { described_class.create_admin_utilities! }

    it 'generates admin utility views within Redshift' do
      expect { subject }.to change(described_class, :admin_uilities_exists?).from(false).to(true)
    end
  end

  describe '.remove_admin_utilities!' do
    subject { described_class.remove_admin_utilities! }

    context 'w/ admin views exist' do
      before { described_class.create_admin_utilities! }

      it 'removes existing admin views' do
        expect { subject }.to change(described_class, :admin_uilities_exists?).from(true).to(false)
      end
    end

    context 'w/ no admin views exist' do
      it 'does nothing' do
        expect { subject }.to_not change(described_class, :admin_uilities_exists?).from(false)
      end
    end
  end

  describe '.admin_uilities_exists?' do
    subject { described_class.admin_uilities_exists? }

    let(:create_test_v_generate_tbl_ddl) do
      Postshift.connection.exec('CREATE OR REPLACE VIEW admin.v_generate_tbl_ddl AS SELECT 1 AS test;')
    end

    let(:create_test_v_generate_view_ddl) do
      Postshift.connection.exec('CREATE OR REPLACE VIEW admin.v_generate_view_ddl AS SELECT 1 AS test;')
    end

    context 'w/ no admin utility views exist' do
      it { is_expected.to be false }
    end

    context 'w/ v_generate_tbl_ddl exists' do
      before { create_test_v_generate_tbl_ddl }
      it { is_expected.to be false }
    end

    context 'w/ v_generate_view_ddl exists' do
      before { create_test_v_generate_view_ddl }
      it { is_expected.to be false }
    end

    context 'w/ v_generate_tbl_ddl & v_generate_view_ddl exist' do
      before { create_test_v_generate_tbl_ddl }
      before { create_test_v_generate_view_ddl }
      it { is_expected.to be true }
    end
  end

  describe '.generate_ddl_sql' do
    context 'for v_generate_tbl_ddl' do
      subject { described_class.generate_ddl_sql('v_generate_tbl_ddl') }
      it { is_expected.to start_with '--DROP VIEW admin.v_generate_tbl_ddl' }
    end

    context 'for v_generate_view_ddl' do
      subject { described_class.generate_ddl_sql('v_generate_view_ddl') }
      it { is_expected.to start_with '--DROP VIEW admin.v_generate_view_ddl' }
    end
  end

  describe '.dump' do
    before { described_class.create_admin_utilities! }
    before { described_class.dump }
    subject { File.open(File.join(Postshift.root, 'tmp', Postshift::Schema::FILENAME)).read }

    it 'includes create table statements' do
      is_expected.to include 'CREATE TABLE IF NOT EXISTS public.ar_internal_metadata'
    end

    it 'includes create view statements' do
      is_expected.to include 'CREATE OR REPLACE VIEW public.v_test_dump'
    end
  end

  describe '.dump_sql' do
    before { clear_tmp }
    subject { described_class.dump_sql }

    context 'w/ file exists at output_location' do
      before { File.write described_class.output_location, 'dump-output' }
      it { is_expected.to eq 'dump-output' }
    end

    context 'w/ no file at output_location' do
      it { is_expected.to be false }
    end
  end

  describe '.restore' do
    before { allow(Postshift).to receive(:connection).and_return double(exec: true) }
    subject { described_class.restore }

    context 'w/ dump file does not exist' do
      before { allow(described_class).to receive(:dump_sql).and_return false }

      it { is_expected.to be_nil }
      it { expect(Postshift).to_not have_received(:connection) }
    end

    context 'w/ dump file' do
      before { allow(Postshift.connection).to receive(:exec) }
      before { allow(described_class).to receive(:dump_sql).and_return 'restore sql' }
      before { subject }
      it { expect(Postshift.connection).to have_received(:exec).with('restore sql') }
    end
  end

  describe '.ddl_results' do
    before { described_class.create_admin_utilities! }
    subject { described_class.ddl_results(described_class.tbl_ddl_sql) }

    it { is_expected.to be_instance_of PG::Result }
  end

  describe '.output_location' do
    subject { described_class.output_location }

    context 'w/ Rails is available' do
      before do
        stub_const('Rails', double(root: 'rails-root'))
      end

      it 'outputs to postshift_schema in Rails db folder' do
        is_expected.to eq File.join('rails-root', 'db', 'postshift_schema.sql')
      end
    end

    context 'w/ outside of Rails' do

      context '& /tmp directory exists' do
        before { Dir.mkdir(base_path) unless Dir.exist?(base_path) }

        it 'outputs to postshift_schema in gem temp folder' do
          is_expected.to eq File.join(base_path, 'postshift_schema.sql')
        end
      end

      context '& /tmp directory does not exist' do
        before { clear_tmp }

        it 'creates the "tmp" directory' do
          expect { subject }.to change { Dir.exist?(base_path) }.from(false).to(true)
        end
      end
    end
  end

  describe '.schemas' do
    subject { described_class.schemas }

    it 'defaults to "public"' do
      is_expected.to eq %w(public)
    end
  end

  describe '.tbl_ddl_sql' do
    subject { described_class.tbl_ddl_sql }

    it 'selects ddl' do
      is_expected.to match(/SELECT\s+ddl/)
    end

    it 'selects from admin.v_generate_tbl_ddl' do
      is_expected.to match(/FROM\s+admin\.v_generate_tbl_ddl/)
    end

    it 'filters to given schemaname' do
      is_expected.to match(/WHERE\s+schemaname IN \(\$1\)/)
    end

    it 'orders by tablename, then sequence' do
      is_expected.to match(/ORDER BY\s+tablename ASC, seq ASC/)
    end
  end

  describe '.view_ddl_sql' do
    subject { described_class.view_ddl_sql }

    it 'selects ddl' do
      is_expected.to match(/SELECT\s+ddl/)
    end

    it 'selects from admin.v_generate_view_ddl' do
      is_expected.to match(/FROM\s+admin\.v_generate_view_ddl/)
    end

    it 'filters to given schemaname' do
      is_expected.to match(/WHERE\s+schemaname IN \(\$1\)/)
    end

    it 'orders by viewname' do
      is_expected.to match(/ORDER BY\s+viewname ASC/)
    end
  end
end

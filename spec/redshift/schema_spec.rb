require 'redshift_helper'

RSpec.describe Postshift::Schema, type: :model do
  before { ARTest.connect.connection }
  after(:each) { described_class.remove_view! }

  describe '.create_view!' do
    subject { described_class.create_view! }

    it 'generates admin view within Redshift' do
      expect { subject }.to change(described_class, :view_exists?).from(false).to(true)
    end
  end

  describe '.remove_view!' do
    subject { described_class.remove_view! }

    context 'w/ view exists' do
      before { described_class.create_view! }

      it 'removes existing view' do
        expect { subject }.to change(described_class, :view_exists?).from(true).to(false)
      end
    end

    context 'w/ no view exists' do

      it 'does nothing' do
        expect { subject }.to_not change(described_class, :view_exists?).from(false)
      end
    end
  end

  describe '.view_exists?' do
    subject { described_class.view_exists? }

    context 'w/ it does' do
      before { described_class.create_view! }
      it { is_expected.to be true }
    end

    context 'w/ it does not' do
      it { is_expected.to be false }
    end
  end
  

  describe '.generate_tbl_ddl_sql' do
    subject { described_class.generate_tbl_ddl_sql }

    it 'reads redshift ddl utility sql' do
      is_expected.to start_with '--DROP VIEW admin.v_generate_tbl_ddl'
    end
  end

  describe '.dump' do
    before { described_class.create_view! }
    before { described_class.dump }
    subject { File.open(File.join(Postshift.root, 'tmp', Postshift::Schema::FILENAME)).read }

    it 'writes output to a file' do
      is_expected.to start_with '--DROP TABLE "public"."ar_internal_metadata"'
    end
  end

  describe '.ddl_results' do
    before { described_class.create_view! }
    subject { described_class.ddl_results }

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
      let(:base_path) { File.join(Postshift.root, 'tmp') }

      context '& /tmp directory exists' do
        before { Dir.mkdir(base_path) unless Dir.exist?(base_path) }

        it 'outputs to postshift_schema in gem temp folder' do
          is_expected.to eq File.join(base_path, 'postshift_schema.sql')
        end
      end

      context '& /tmp directory does not exist' do
        before { FileUtils.remove_dir(base_path) }

        it 'creates the "tmp" directory' do
          expect { subject }.to change { Dir.exists?(base_path) }.from(false).to(true)
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

  describe '.ddl_sql' do
    subject { described_class.ddl_sql }

    it 'selects ddl' do
      is_expected.to match /SELECT\s+ddl/
    end

    it 'selects from admin.v_generate_tbl_ddl' do
      is_expected.to match /FROM\s+admin\.v_generate_tbl_ddl/
    end

    it 'filters to given schemaname' do
      is_expected.to match /WHERE\s+schemaname IN \(\$1\)/
    end

    it 'orders by tablename, then sequence' do
      is_expected.to match /ORDER BY\s+tablename ASC, seq ASC/
    end
  end
end

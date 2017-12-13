require 'spec_helper'
require 'rspec'
require 'athena_processor'

RSpec.describe AthenaProcessor do
  describe "#new" do
    it "references a valid CSV file" do
      allow(File).to receive(:exists?).with("athena-records.csv").and_return(true)
      tool = AthenaProcessor.new "athena-records.csv"
      expect(tool.csv_path).to eq "athena-records.csv"
    end

    it "fails if the CSV import is unavailable" do
      expect { AthenaProcessor.new "null-path" }.to raise_error(FileNotFoundError)
    end
  end

  describe "#import" do
    before(:each) do
      ATHENA_DB.disconnect
      ATHENA_DB = Sequel.sqlite
      ATHENA_DB.create_table? :accessions do
        primary_key :id
        String :accession_number
        String :category
      end
      AthenaRecord.dataset = ATHENA_DB[:accessions]
    end

    it "imports the records into the database" do
      processor = AthenaProcessor.new "spec/fixtures/athena-mock.csv"
      processor.import

      expect(AthenaRecord.count).to eq(5)
 
      record = AthenaRecord.first
      expect(record[:accession_number]).to eq "1.2001"
      expect(record[:category]).to eq "long-term loan"
    end
  end
end

require 'spec_helper'
require 'rspec'
require 'csv_importer'

require 'pry'

RSpec.describe CsvImporter do
  describe "#new" do
    it "loads a valid CSV resource" do
      allow(File).to receive(:exists?).with("valid-input.csv").and_return(true)
      tool = CsvImporter.new "valid-input.csv"
      
      expect(tool.csv_path).to eq "valid-input.csv" 
    end

    it "raises an error if the file path is invalid" do
      expect { CsvImporter.new "no-such-file" }.to raise_error(FileNotFoundError)
    end
  end

  describe "#import_to" do
    let(:db) { Sequel.sqlite(database: "rspec.db") }
    before(:each) do 
      db.create_table? :sources do
        primary_key :id
        String :accession_number
        String :accession_master
        Date :date_created
        String :dvd
        String :source
      end  
      db[:sources].truncate
    end

    after(:all) do
      File.delete("rspec.db")
    end

    it "exports the records into the database" do
      tool = CsvImporter.new 'spec/fixtures/valid-import.csv'
      db_table = db[:sources]
      tool.import_to db_table

      expect(db_table.count).to be 7
      
      record = db_table.first
     
      expect(record[:accession_number]).to eq "1.1997"
      expect(record[:accession_master]).to eq "1.1997"
      expect(record[:dvd]).to eq "0769"
      expect(record[:source]).to eq "CAMERA"
      expect(record[:date_created]).to eq Sequel.string_to_date("2007-07-01")

      record = db_table.where(id: 2).first
        
      expect(record[:date_created]).to be_nil
    end

    it "handles malformed dates" do
      tool = CsvImporter.new 'spec/fixtures/invalid-dates.csv'
      db_table = db[:sources]
      tool.import_to db_table

      expect(db_table.count).to be 1
      
      record = db_table.first
     
      expect(record[:accession_number]).to eq "1.2007"
      expect(record[:accession_master]).to eq "1966.482_1.2007"
      expect(record[:dvd]).to eq "0859"
      expect(record[:source]).to eq "CAMERA"
      expect(record[:date_created]).to be_nil
    end
  end
end

require 'spec_helper'
require 'rspec'
require 'photostudio_processor'

RSpec.describe PhotostudioProcessor do
  describe "#new" do
    it "loads a valid CSV resource" do
      allow(File).to receive(:exists?).with("valid-input.csv").and_return(true)
      tool = PhotostudioProcessor.new "valid-input.csv"
      
      expect(tool.csv_path).to eq "valid-input.csv" 
    end

    it "raises an error if the file path is invalid" do
      expect { PhotostudioProcessor.new "no-such-file" }.to raise_error(FileNotFoundError)
    end
  end

  describe "#import" do
    before(:each) do 
      PHOTO_DB.disconnect
      PHOTO_DB = Sequel.sqlite
      PHOTO_DB.create_table? :sources do
        primary_key :id
        String :accession_number
        String :accession_master
        Date :date_created
        String :dvd
        String :source
      end
      PhotostudioRecord.dataset = PHOTO_DB[:sources]  
    end

    it "imports the records into the database" do
      tool = PhotostudioProcessor.new 'spec/fixtures/valid-import.csv'
      tool.import
   
      expect(PhotostudioRecord.count).to eq(7)
      
      record = PhotostudioRecord.first
      expect(record[:accession_number]).to eq "1.1997"
      expect(record[:accession_master]).to eq "1.1997"
      expect(record[:dvd]).to eq "0769"
      expect(record[:source]).to eq "CAMERA"
      expect(record[:date_created]).to eq Sequel.string_to_date("2007-07-01")

      record = PhotostudioRecord.first(id: 2)
      expect(record[:date_created]).to be_nil
    end

    it "handles malformed dates" do
      tool = PhotostudioProcessor.new 'spec/fixtures/invalid-dates.csv'
      tool.import

      expect(PhotostudioRecord.count).to eq(1)
      
      record = PhotostudioRecord.first
      expect(record[:accession_number]).to eq "1.2007"
      expect(record[:accession_master]).to eq "1966.482_1.2007"
      expect(record[:dvd]).to eq "0859"
      expect(record[:source]).to eq "CAMERA"
      expect(record[:date_created]).to be_nil
    end
  end
end

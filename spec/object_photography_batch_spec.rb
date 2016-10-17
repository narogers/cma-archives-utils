require 'spec_helper'
require 'object_photography_batch'
require 'sequel'

RSpec.describe ObjectPhotographyBatch do
  describe "#include?" do
    let(:batch) { ObjectPhotographyBatch.new }

    it "processes RAW images" do
      expect(batch.include?("file-name.dng")).to be true
    end  

    it "processes TIFF images" do
      expect(batch.include?("file-name.tif")).to be true
    end

    it "processes JPEG images" do
      expect(batch.include?("file-name.jpg")).to be true
    end

    it "processes Photoshop files" do
      expect(batch.include?("file-name.psd")).to be true
    end

    it "processes XMP files" do
      expect(batch.include?("file-name.xmp")).to be true
    end
  end

  describe "#add_files" do
    it "adds Object specific metadata" do
      allow(Find).to receive(:find).and_yield("")

      batch = ObjectPhotographyBatch.new
      batch.process("DVD2005")
      batch.add_file("test-1.dng", nil)

      expect(batch.files.size).to be 1

      file = batch.files["test-1.dng"]
      expect(file.metadata[:part_of]).to eq "DVD2005"
    end

    it "pulls information from the photography database" do
      allow(Find).to receive(:find).and_yield("")
      
      batch = ObjectPhotographyBatch.new
      batch.load_photostudio_db "spec/fixtures/photostudio-mock.db"
      batch.process("DVD0452")
      batch.add_file("2014.12.tif", nil)

      expect(batch.files.size).to be 1
 
      file = batch.files["2014.12.tif"]
      expect(file.metadata[:part_of]).to eq "DVD0452"
      expect(file.metadata[:source]).to eq "Topaz"
      expect(file.metadata[:date_created]).to eq "2005-02-01"
    end

    it "handles weekly batch ingests" do
      allow(Find).to receive(:find).and_yield("")
      batch = ObjectPhotographyBatch.new
      batch.load_photostudio_db "spec/fixtures/photostudio-mock.db"
      batch.process("WIB095")
      batch.add_file("1992.394.tif", nil)

      expect(batch.files.size).to be 1

      file = batch.files["1992.394.tif"]
      expect(file.metadata[:part_of]).to eq "WIB095"
      expect(file.metadata[:source]).to eq "CAMERA"
      expect(file.metadata[:date_created]).to be_nil
    end
  end

  describe "#is_parseable?" do
    let(:batch) { ObjectPhotographyBatch.new }
    
    it "should be named with DVDxxxx" do
      expect(batch.is_parseable?("DVD8351")).to be true
    end

    it "should not allow malformed titles" do
      expect(batch.is_parseable?("DVD 2510")).to be false
    end
  
    it "ignores nonzero padded numbers" do
      expect(batch.is_parseable?("DVD192")).to be false
    end

    it "allows Weekly Batches (WIB)" do
      expect(batch.is_parseable?("WIB 21")).to be true
    end
  end

  describe "#extract_title" do
    let(:batch) { ObjectPhotographyBatch.new }

    it "processes DVD prefixed directories" do
      title = batch.extract_title("DVD2417")
      
      expect(title).to eq "DVDs 2410 to 2419"
    end

    it "returns invalid values as is" do
      title = batch.extract_title("Badly_Named_Directory")
      
      expect(title).to eq "Badly_Named_Directory"
    end
  end

  describe "#process" do
    let(:files) do
      ["test-1.dng", "test-2.tif", "test-3.tiff", "test-4.jpg", "test-5.psd"]
    end
    it "should process a directory without any errors" do
      batch = ObjectPhotographyBatch.new
      find_mock = allow(Find).to receive(:find)
      files.each do |f|
        find_mock.and_yield(f)
      end
      batch.process("DVD0919")

      expect(batch.files.count).to eq 5
      
      tiff = batch.files["test-2.tif"]
      expect(tiff.metadata[:part_of]).to eq "DVD0919"
    end
  end

  describe "#load_photostudio_db" do
    let(:batch) { ObjectPhotographyBatch.new }
    
    it "initializes the database connection" do
      batch.load_photostudio_db("spec/fixtures/photostudio-mock.db")
      expect(batch.database.class).to eq Sequel::SQLite::Database
    end

    it "throws an error when the table is missing" do
      expect { batch.load_photostudio_db "spec/fixtures/bad-db-path" }.to raise_error(RuntimeError)
      File.delete("spec/fixtures/bad-db-path")
    end
  end
end

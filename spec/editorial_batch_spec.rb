require 'spec_helper'
require 'editorial_batch'

require 'pry'

RSpec.describe EditorialBatch do
  describe "#include?" do
    let(:batch) { EditorialBatch.new }

    it "processes RAW images" do
      expect(batch.include?("file-name.dng")).to be true
    end  

    it "processes TIFF images" do
      expect(batch.include?("file-name.tif")).to be true
    end

    it "processes JPEG images" do
      expect(batch.include?("file-name.jpg")).to be true
    end

    it "skips Photoshop files" do
      expect(batch.include?("file-name.psb")).to be false
    end
  end

  describe "#add_files" do
    let(:batch) { EditorialBatch.new }
    
    it "adds editorial specific metadata" do
      batch.extract_title("2015-01-12 DB Another Museum Event")
      batch.add_file("test-1.dng", nil)
     
      expect(batch.properties[:photographer]).to eq "David Brichford"
      expect(batch.files.size).to be 1

      file = batch.files["test-1.dng"]
      expect(file.metadata[:photographer]).to eq "David Brichford"
    end
  end

  describe "#is_parseable?" do
    let(:batch) { EditorialBatch.new }
    
    it "should only allow XXXX-XX-XX date formats" do
      expect(batch.is_parseable?("20100819 Bad Directory Name")).to be false
    end

    it "should ignore -DELETED dictories" do
      expect(batch.is_parseable?("My_Collection-DELETED")).to be false
    end

    it "should ignore underscores" do
      expect(batch.is_parseable?("2018-03-12_GD_A_Test_Collection")).to be true
    end
  
    it "should ignore directories with no title" do
      expect(batch.is_parseable?("2006-02-09 HA")).to be false
    end
  end

  describe "#extract_title" do
    let(:batch) { EditorialBatch.new }

    it "processes ED prefixed dictories" do
      allow(Find).to receive(:find).and_yield("")
      batch.process("ED192/2014-12-29 Sample Collection")
      
      expect(batch.properties[:photographer]).to be_nil
      expect(batch.properties[:part_of]).to eq "ED192"
      expect(batch.properties[:category]).to be_nil
    end

    it "creates a category property" do
      allow(Find).to receive(:find).and_yield("")
      batch.process("Special_Exhibitions/2012-10-12 Mughal India")
      
      expect(batch.properties[:photographer]).to be_nil
      expect(batch.properties[:part_of]).to be_nil
      expect(batch.properties[:category]).to eq "Special Exhibitions"
    end
  end

  describe "#process" do
    let(:files) do
      ["test-1.dng", "test-2.tif", "test-3.tiff", "test-4.jpg", "test-5.psd"]
    end
    it "should process a directory without any errors" do
      batch = EditorialBatch.new
      find_mock = allow(Find).to receive(:find)
      files.each do |f|
        find_mock.and_yield(f)
      end
      batch.process("2012-04-24 HA RSpec Demonstration")

      expect(batch.files.count).to eq 4
      
      dng_image = batch.files["test-1.dng"]
      expect(dng_image.metadata[:source]).to eq "2012-04-24 HA RSpec Demonstration/test-1.dng"
      expect(dng_image.metadata[:title]).to eq "2012-04-24 HA RSpec Demonstration - test-1.dng"
      expect(dng_image.metadata[:photographer]).to eq "Howard Agriesti"
    end
  end
end

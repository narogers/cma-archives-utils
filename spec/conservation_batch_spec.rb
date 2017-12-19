require 'spec_helper'
require 'rspec'
require 'conservation_batch'

RSpec.describe ConservationBatch do
  describe '#include?' do
    let(:batch) { ConservationBatch.new }

    it "processes RAW images" do
      expect(batch.include?("archival-image.dng")).to be true
    end
    it "processes TIFF images" do
      expect(batch.include?("archival-image.tif")).to be true
    end
    it "processes Photoshop master images" do
      expect(batch.include?("archival-image.psd")).to be true
      expect(batch.include?("archival-image.psb")).to be true
    end
    it "processes JPEG images" do
      expect(batch.include?("archival-images.jpg")).to be true
    end
  end

  describe "#process_directory?" do
    let(:batch) { ConservationBatch.new }
    it "accepts only directories which start with accession numbers" do
      valid_path = "Textile Labs/Imaging/2000.15_Images_for_Study"
      invalid_path = "Paper Labs/Sketches/Image_Of_A_Cat"

      expect(batch.process_directory? valid_path).to be true
      expect(batch.process_directory? invalid_path).to be false
    end
  end

  describe "#is_parseable?" do
    let(:batch) { ConservationBatch.new }

    it "accepts only paths with accession numbers" do
      expect(batch.is_parseable? "2014.23_BT_NL.tif").to be true
      expect(batch.is_parseable? "AT_MIC_DET04_1945.113").to be false
    end
  end

  describe "#process" do
    it "extracts metadata from the directory name" do 
      files = ["P0143423.jpg", "P0331234.jpg"]
      file_mock = allow(Find).to receive(:find)
      files.each { |f| file_mock.and_yield(f) }

      batch = ConservationBatch.new
      batch.process("/Textile Lab/1972.43_Dragon_Statue")
      expect(batch.files.count).to eq 2
     
      metadata = batch.files["P0143423.jpg"].metadata
      expect(metadata[:accession_number]).to eq "1972.43"
      expect(metadata[:title]).to eq "P0143423.jpg" 
      expect(metadata[:division]).to eq "Textile Lab"
    end

    it "extracts metadata from the file names" do
      files = ["2007.14_NL_BT_REC.dng", "2007.14_NL_BT_VER.dng"]
      file_mock = allow(Find).to receive(:find)
      files.each { |f| file_mock.and_yield(f) }

      batch = ConservationBatch.new
      batch.process("/Objects Lab/2012.23_Different_Object/")
      expect(batch.files.count).to eq 2

      metadata = batch.files["2007.14_NL_BT_REC.dng"].metadata
      expect(metadata[:accession_number]).to eq "2012.23|2007.14"
      expect(metadata[:lighting]).to eq "Normal light"
      expect(metadata[:component]).to eq "Recto"
      expect(metadata[:conservation_state]).to eq "Before Treatment"
    end

    it "handles nested directories" do
      files = ["DirOne/custom_image.tif", "DirTwo/custom_image.jpg"]
      file_mock = allow(Find).to receive(:find)
      files.each { |f| file_mock.and_yield(f) }

      batch = ConservationBatch.new
      batch.process("/2012.23_Different_Object")
      expect(batch.files.count).to eq 2

      metadata = batch.files["DirTwo/custom_image.jpg"].metadata
      expect(metadata[:accession_number]).to eq "2012.23"
      expect(metadata[:title]).to eq "DirTwo/custom_image.jpg"
    end
  end
end

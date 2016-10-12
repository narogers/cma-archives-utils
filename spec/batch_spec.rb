require 'spec_helper'
require 'batch'

require 'pry'

RSpec.describe Batch do
  let(:batch) { Batch.new }

  after(:each) do
    batch.files = []
    batch.metadata_fields = {}
  end

  describe "#include?" do
    it "should ignore dot files" do
      expect(batch.include? ".hidden_file").to be false       
    end

    it "should ignore batch manifests" do
      expect(batch.include? "file_list.csv").to be false
    end

    it "should process text files" do
      expect(batch.include? "checklist.txt").to be true
    end
  end

  describe "#add_file" do
    it "adds a file without metadata" do
      batch.add_file("test-1", nil)
      expect(batch.files.size).to eq 1
      
      entry = batch.files["test-1"]
      expect(entry.path).to eq "test-1"
      expect(entry.metadata).to be_empty
    end
  end

  describe "#delete_file" do
    it "deletes a file from the manifest" do
      batch.add_file("test-2", nil)
      batch.add_file("test-3", nil)
      batch.delete_file("test-2")
      
      expect(batch.files.size).to eq 1
    end
  end

  describe "#manifest" do
    after(:each) do
      File.delete("test.csv") if File.exists?("test.csv")
    end

    it "generates a valid manifest file" do
      batch.add_file "test-2.dng", {subject: "Unit Testing", description: "A mock file"}
      batch.add_file "test-3.tif", {subject: "Unit Testing"}
      batch.add_file "test-4.txt", {title: "Title Field"}
      batch.manifest "test.csv"
      manifest = CSV.read("test.csv", "r")

      expect(manifest.count).to be 8
      expect(manifest[1]).to eq ["clio-batches"]
      
      files = manifest.drop(5)

      expect(files.count).to be 3
      expect(files[0][0]).to eq "test-2.dng"
      expect(files[0][2]).to eq "A mock file"
      expect(files[2][0]).to eq "test-4.txt"
      expect(files[2][4]).to eq "Title Field"
    end
  end

  describe "#process" do
    let(:batch) { Batch.new }
    let(:path) { "ED019/" }
    let(:file_set) do
      ["ED019/testFile.txt",
       "ED019/2013-01 repository-image.tif",
       "ED019/2012-01-14 HA Sample Image.jpg",
       "ED019/myBatch.csv"]
    end

    it "processes a directory of files" do
      find_mock = allow(Find).to receive(:find)
      file_set.each do |file|
        find_mock.and_yield(file)
      end

      batch.process path
    
      expect(batch.files.count).to be 3
      batch.files.each_pair do |file, metadata|
        expect(file).to eq metadata.metadata[:title]
      end
    end
  end

  describe "#is_parseable?" do
    let(:batch) { Batch.new }

    it "always return true" do
      expect(batch.is_parseable? nil).to be true
      expect(batch.is_parseable? "Nonsense").to be true      
    end
  end
end

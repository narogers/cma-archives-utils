require 'spec_helper'
require 'batch_file'

RSpec.describe "BatchFile" do
  describe "add_metadata" do
    let(:properties) do
      {title: "Title Attribute",
       subject: "Royal Servant",
       creator: "Unit Test Harness"}
    end
   
    it "adds a hash of properties" do
      file = BatchFile.new "RSpec.txt"
      file.add_attributes(properties)
      
      expect(file.metadata.keys.count).to be 3
      expect(file.metadata[:title]).to eq "Title Attribute"
      expect(file.metadata[:subject]).to eq "Royal Servant"
      expect(file.metadata[:creator]).to eq "Unit Test Harness"
    end

    it "adds a key / value pair" do
      file = BatchFile.new "RSpec.txt"
      file.add_attribute(:photographer, "Greg Donley")
      
      expect(file.metadata[:photographer]).to eq "Greg Donley"
    end
  end

  describe "#delete_metadata" do
    it "removes attributes" do
      file = BatchFile.new "RSpec.txt"
      file.add_attribute(:photographer, "Greg Donley")

      expect(file.metadata.keys.count).to be 1

      file.delete_attribute :photographer
   
      expect(file.metadata.keys.count).to be 0
    end

    it "ignores properties which do not exist" do
      file = BatchFile.new "RSpec.txt"
      expect(file.delete_attribute(:photographer)).to be nil
    end
  end
end

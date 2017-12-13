require 'spec_helper'
require 'batch_utils'

RSpec.describe BatchUtils do
  describe '#accession_number' do
    it "returns a valid pattern for accession numbers" do
      expect("2013.51".match BatchUtils.accession_number).to be_truthy
      expect("2004.193.a".match BatchUtils.accession_number).to be_truthy
      expect("a_1956.72".match BatchUtils.accession_number).to be_falsey
    end    
  end
end

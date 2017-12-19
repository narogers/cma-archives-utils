# Helper methods for working with directories to create batch ingest
# manifests
module BatchUtils
  # Pattern(s) for matching an accession number based on CMA standards 
  def self.accession_number 
    return /^(\d{2,}\.\d+)/  
  end  
end

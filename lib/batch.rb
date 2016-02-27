class Batch
  attr_accessor :collection_title, :files, :metadata_fields
 
  def initialize
    @collection_title = DateTime.now.strftime("%Y-%02M-%02d")
    @files = []
    @metadata_fields = []
  end

  # Given a file determine if it should be included in the manifest or not.
  # Override this method in children to behave as expected for different types
  # of collections
  def include?(file_name) 
    return true
  end

  # Sets the owner for the collection when it is ingested into the repository.
  # This value gets written out as a header in each manifest. Override for specific
  # cases as needed.
  def owner
    "clio-batches"
  end

  # Defines the parent collection that this batch should belong to. Override in
  # children to replace the default of none
  def parent_collection
    nil
  end

  # Override to customize the way that the manifest file is created for this
  # batch. By default it uses the format below
  #
  # Collection Title
  # owner
  # parent_collection
  #
  # metadata_headers
  # file_metadata
  def manifest(output = nil)
    # Default to STDOUT unless otherwise provided
    output ||= STDOUT
    output << self.collection_title
    output << self.owner
    output << self.parent_collection
    output << ""
    output << self.manifest_header
    files.each { |f| output << f.to_s }
  end

  def manifest_header
    output = ([:file] << @metadata_fields.sort).flatten
    output.join(", ")
  end
end


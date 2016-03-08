require 'batch_file'
require 'csv'
require 'find'

class Batch
  attr_accessor :collection_title, :files, :metadata_fields
 
  def initialize
    @collection_title = DateTime.now.strftime("%Y-%02m-%02d")
    @files = {}
    @properties = {}
  end

  def process(directory)
    @collection_title = extract_title(directory)
    # Traverse the directory structure and, if a file should be included in the
    # manifest, register it
    print "[#{File.basename(directory)}]\n"
    Find.find(File.expand_path(directory)) do |path|
      print "#{File.basename(path)}\n"
      # Subdirectories are not supported at the current time
      next if File::directory? path
     
      file = File.basename(path)
      if include? file
        add_file(file, generate_metadata(directory, file))
      end
    end
    print "\n"
  end

  # Given a file determine if it should be included in the manifest or not.
  # Override this method in children to behave as expected for different types
  # of collections
  def include?(file_name) 
    include_file = true
    include_file = !(file_name.start_with? ".")
    include_file = !(file_name.end_with? ".csv")

    include_file
  end

  def add_file(file_name, metadata)
    file = BatchFile.new(file_name)
    metadata.each_pair do |key, value|
      @properties[key] = nil unless @properties.include? key
      file.add_metadata(key, value)
    end
    @files[file_name] = file
  end

  def delete_file(file_name)
    @files.delete(file_name)
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
  def manifest(output_file = nil)
    output_file ||= "batch-#{DateTime.now.strftime("%Y%02m%02d%02H%02M%02S")}.csv"

    output = CSV.open(output_file, "w")
    output << [self.collection_title]
    output << [self.owner]
    output << [self.date_created]
    output << [self.parent_collection] unless parent_collection.nil?
    output << []
    output << self.manifest_header
   
    files.each_pair do |name, file| 
      csv_for_file = [name]
      @properties.keys.sort.each do |field|
        csv_for_file << file.metadata[field]
      end
      output << csv_for_file
    end

    output.close
  end

  protected
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

    def manifest_header
      ([:file] << @properties.keys.sort).flatten
    end
  
    # Date that the batch was created. You can override this in a subclasses
    # to provide something other than the current time
    def date_created
      @date_created ||= Date.today
    end
 
    # Determines the name of the batch. Override in a subclass for more specific
    # behaviour
    def extract_title(path)
      "Automated Batch #{DateTime.now.strftime("%Y%02m%02d%02H%02M")}"
    end

    # Extracts file metadata. Override in subclasses to get more sophisticated
    # behaviours
    def generate_metadata(directory, file_name)
      {title: file_name}
    end
end



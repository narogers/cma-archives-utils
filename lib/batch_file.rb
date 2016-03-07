class BatchFile
  attr_accessor :path, :metadata

  def initialize(resource)
    self.path = resource
    self.metadata = {}
  end

  # Attributes should be a series of one or more key: value pairs which you
  # want to apply to the resource
  def add_metadata(attributes)
    attributes.each_pair do |field, value|
      add_metadata(field, value)
    end
  end

  def add_metadata(field, value)
    self.metadata[field] = value
  end

  def delete_metadata(field)
    self.metadata.remove(field) if self.metadata.exists? field
  end
end

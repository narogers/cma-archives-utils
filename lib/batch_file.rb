class BatchFile
  attr_accessor :path, :metadata

  def initialize resource
    self.path = resource
    self.metadata = {}
  end

  # Attributes should be a series of one or more key: value pairs which you
  # want to apply to the resource
  def add_attributes attributes
    attributes.each_pair do |field, value|
      add_attribute(field, value)
    end
  end

  def add_attribute field, value
    self.metadata[field] = value
  end

  def delete_attribute field
    self.metadata.delete field if self.metadata.has_key? field
  end
end

class Resource
  attr_accessor :path, :metadata

  def initialize
    self.metadata = {}
  end

  # Attributes should be a series of one or more key: value pairs which you
  # want to apply to the resource
  def add_metadata(attributes)
    attributes.each_pair do |k, v|
      self.metadata[k] = v
    end
  end

  def delete_metadata(field)
    self.metadata.remove(field) if self.metadata.exists? field
  end

  def to_s
    output = :path
    self.metadata.keys.sort.each do |k|
      output << ", #{metadata[k]}"
    end
    
    output
  end
end

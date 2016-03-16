require 'batch'

class ObjectPhotographyBatch < Batch
  def include? file_name
    super &&
      allowed_extensions.include? File.extname(file_name).downcase
  end

  def add_file
    super
    [:part_of].each do |key|
      if @properties.include? key
        @files[file].add_metadata(key, @properties[key])
      end
    end
  end

  protected
    def parent_collection
      "Object Photography"
    end
    
    def allowed_extensions
      [
        ".tif", # image/tiff,
        ".tiff" # image/tiff
      ]
    end

    def extract_title directory
      if directory.include? File::Separator
        parent_directory.split(File::Separator)[-2]
        if parent_directory.start_with? "DVD"
          @properties[:part_of] = parent_directory
        end
      end
      # TODO: Anything else?
    end

    def generate_metadata directory, file
      if (/(^\d+\.\d+\.?\d+?)/ =~ file)
        @properties[:accession] = $1
      end
    end

    def is_parseable? title
      return (0 == (/^DVD\d{4}/ =~ title))
    end
end

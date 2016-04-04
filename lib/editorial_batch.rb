require 'batch'

class EditorialBatch < Batch
  def include? file_name
    super && 
      allowed_extensions.include?(File.extname(file_name).downcase)
  end

  def add_file(file, metadata)
    super
    
    # Now we augment the batch file with some global metadata (specifically the
    # optional photographer, category, and DVD number)
    [:photographer, :part_of, :category].each do |key|
      if @properties.include? key
        @files[file].add_metadata(key, @properties[key])
      end
    end
  end

  protected
    def parent_collection
      "Editorial Photography"
    end

    def allowed_extensions
      [
        ".dng", # Adobe RAW
        ".jpg", # image/jpg
        ".jpeg", # image/jpeg
        ".tif", # image/tiff
        ".tiff", # image/tiff
      ]
    end
    
    def photographers
      {"DB" => "David Brichford",
       "HA" => "Howard Agriesti",
       "GD" => "Greg Donley"}
    end

    # Some titles may have stray characters; strip out any unwanted = or
    # _ to create a human readable label. Also during ingest the repository's
    # titleize will further fix any casing issues so these can be ignored
    # at this stage
    #
    # The assumption is made that the directory structure looks like
    # ED319/2013-01-12 HA An Amazing Museum Event
    # or
    # Events/2013-01-12 HA An Amazing Museum Event
    #
    # Any extra directories will be ignored. If not provided the category
    # or batch is simply glossed over ('2013-01-12 HA An Amazing Museum
    # Event')
    def extract_title directory
      batch_directory = directory
      # TODO: These really should not be side effects of calling a different
      #       method
      if directory.include? File::Separator
        parent_directory = directory.split(File::Separator)[-2]
        if (parent_directory.start_with? "ED")
          @properties[:part_of] = parent_directory
        else
          @properties[:category] = parent_directory
        end
        batch_directory = directory.split(File::Separator).last
      end
      batch_directory.gsub!("_", " ")

      # First is always a date (2013-01)
      # Second may be an optional photographer
      # The rest is the title
      batch_details = batch_directory.split(" ")
      @date_created = batch_details.shift
      if (batch_details.first.match(/^[A-Z]{2}$/))
        photographer = photographers[batch_details.shift]
        @properties[:photographer] = photographer
      end
      # Drop the last value if it is a two digit integer such as '01',
      # '02', etc
      if (batch_details.last.match(/^[01]\d$/))
        batch_details.pop
      end

      # Return the batch title
      batch_details.join(" ") 
    end

    def generate_metadata(directory, file)
      directory = directory.split("/").last 
      {
        source: "#{directory}#{File::Separator}#{file}",
        title: "#{directory} - #{file}"
      }
    end

    # A valid directory title should be structured as either
    #
    # 2015-12-01_DB_Title_for_Collection [new style]
    # OR
    # 2005-01 RM Event name [old style]
    def is_parseable? title
      # Normal pattern
      valid_regex = /^\d{4}-\d{2}-?\d{2}?\s([A-Z]{2}\s)?\w+/
      # But add exceptions if only a photographer is supplied or for
      # other patterns that would otherwise match above
      invalid_regexes = [
        /^\d{4}-\d{2}-?\d{2}?\s[A-Z]{2}$/,
        /-DELETED$/
      ] 
    
      # Begin with the invalid regex pattern(s) first
      invalid_regexes.each do |regex|
        return false if (regex =~ title)
      end
      # Otherwise validate against the template
      return ((valid_regex =~ title) == 0)
    end
end

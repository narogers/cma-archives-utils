require 'batch'

class ObjectPhotographyBatch < Batch
  def include? file_name
    super &&
      allowed_extensions.include?(File.extname(file_name).downcase)
  end

  def add_file file, metadata
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
      title = directory
      if directory.include? File::Separator
        directory.split(File::Separator)[-2]
        if directory.start_with? "DVD"
          @properties[:part_of] = directory
          # Due to collection membership constraints in Fedora that
          # cause performance to suffer with more than 2,000 members in
          # a single collection we group the DVDs into batches of ten
          #
          # This gives us well over 20 years of weekly ingests to solve
          # the scalability problem
          if (directory =~ /^DVD(\d{4})/)
            # If we don't specify Base 10 the leading 0s may resolve it to
            # hex instead ("0056" => 46)
            dvd_start = (Integer $1, 10) / 10
            dvd_end = dvd_start + 9
            title = "DVDs #{dvd_start} to #{dvd_end}"
          end
        end
      end

      title
    end

    def generate_metadata directory, file
      metadata = {}
      if (/(^\d+\.\d+\.?\d+?)/ =~ file)
        metadata[:accession] = $1
      end
     
      metadata
    end

    # TODO: Revisit once the prefix switches to WIB so it does not ignore
    #       ongoing weekly batches
    def is_parseable? title
      return (0 == (/^DVD\d{4}/ =~ title))
    end
end

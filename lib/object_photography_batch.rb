require 'batch'
require 'sequel'

class ObjectPhotographyBatch < Batch
  attr :photography_db

  def include? file_name
    super &&
      allowed_extensions.include?(File.extname(file_name).downcase)
  end

  def add_file file, metadata
    super
    [:part_of].each do |key|
      if @properties.include? key
        @files[file].add_attribute(key, @properties[key])
      end

      unless @photography_db.nil?
        # DVD number = part_of - "DVD"
        # Accession master = file name - extension
        #
        # If you find a match in the database add the Date Created and
        # Sources to the manifest
        accession_master = File.basename(file, ".*")
        dvd = @properties[:part_of].sub("DVD", "")

        metadata = @photography_db.where(accession_master: accession_master,
          dvd: dvd).first
        unless metadata.nil?
          @files[file].add_attribute(:source, metadata[:source])

          date_created = metadata[:date_created].nil? ?
             nil :
             metadata[:date_created].strftime("%Y-%m-%d")
          @files[file].add_attribute(:date_created, date_created)
        end
      end
    end
  end

  def extract_title directory
    title = directory
    if directory.include? File::Separator
      directory = directory.split(File::Separator).last
    end  
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
        dvd_start = ((Integer $1, 10) / 10) * 10
        dvd_end = dvd_start + 9
        # Restore zero padding
        dvd_start = sprintf("%04d", dvd_start)
        dvd_end = sprintf("%04d", dvd_end)
        title = "DVDs #{dvd_start} to #{dvd_end}"
      end
    end

    title
  end

  def is_parseable? title
    ((0 == (/^DVD\d{4}/ =~ title)) ||
     (title.start_with? "WIB"))
  end

  def load_photostudio_db path
    @database = Sequel.sqlite(database: path)
    @photography_db = @database[:sources]
  end

  protected
    def parent_collection
      "Object Photography"
    end
    
    def allowed_extensions
      [
        ".dng", # image/x-adobe-dng,
        ".jpg", # image/jpeg,
        ".psd", # Photoshop masters
        ".tif", # image/tiff,
        ".tiff", # image/tiff,
        ".xmp", # application/octet-stream
      ]
    end

    def generate_metadata directory, file
      metadata = {}
      if (/(^\d+\.\d+(\.\d+)?)/ =~ file)
        metadata[:accession_number] = $1
      end
     
      metadata
    end
end

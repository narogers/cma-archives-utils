require 'batch'
require 'batch_utils'
require 'conservation_codes'
require 'pry'

class ConservationBatch < Batch
  attr :properties

  def include? file
    super &&
      allowed_extensions.include?(File.extname(file).downcase)
  end

  # Directories are valid if they begin with an accession number and are
  # not children of another valid directory
  def process_directory? path
    subdirectories = path.split("/")
    index = nil
    subdirectories.each_with_index do |subdirectory, i|
      if subdirectory.match BatchUtils.accession_number
        index = i
        break
      end
    end

    return ((subdirectories.length - 1) == index)  
  end

  def is_parseable? path
    return (not path.match(BatchUtils.accession_number).nil?)
  end

  def generate_metadata(directory, file)
    metadata = {}
    paths = directory.split("/")
    
    paths.each do |p|
      metadata[:division] = [p] if Conservation::DIVISIONS.include? p

      parsed_metadata = parse_path(p)      
      parsed_metadata.delete(:title)

      parsed_metadata.each_pair do |prop, value|
        metadata[prop] ||= []
        metadata[prop] += value
        metadata[prop].uniq!
      end
    end

    parsed_metadata = parse_path(File.basename(file, File.extname(file)))
    parsed_metadata.delete(:title)

    parsed_metadata.each_pair do |prop, value|
      metadata[prop] ||= []
      metadata[prop] += value
      metadata[prop].uniq!
    end
    metadata[:title] = file

    metadata_fields = metadata.keys - [:title]
    metadata_fields.each do |prop|
      metadata[prop] = metadata[prop].join("|")
    end 

    return metadata
  end

  def parse_path path
    metadata = {}
    parts = path.split("_")

    return metadata if parts.empty?

    metadata[:title] = []
    if parts[0].match BatchUtils.accession_number
      accession_number = parts.shift.gsub(/[^0-9.]/, "")
      accession_number.chop if accession_number.end_with? "."
      metadata[:accession_number] = [accession_number]
    end

    parts.each_with_index do |code, i|
      if Conservation::SHORT_CODES[code.to_sym].nil?
        metadata[:title] << code
      else
        expanded_field = Conservation::SHORT_CODES[code.to_sym]
        metadata[expanded_field[1]] ||= []
        metadata[expanded_field[1]] << expanded_field[0]
      end
    end
    metadata[:title] = metadata[:title].join(" ")

    return metadata
  end

  def allowed_extensions
    [".dng", # Adobe RAW
     ".jpg", # image/jpg
     ".jpeg", # image/jpeg
     ".tif", # image/tiff
     ".tiff", # image/tiff
     ".psb", # Photoshop
     ".psd", # Photoshop
    ]
  end

  protected
    def parent_collection
      "Conservation Photography"
    end
end

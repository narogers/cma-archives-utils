require 'csv'
require 'sequel'

class CsvImporter
  attr_accessor :csv_path

  def initialize csv_input
    if File.exists? csv_input
      self.csv_path = csv_input
    else
      raise FileNotFoundError.new("Could not locate #{csv_input}")
    end
  end

  def import_to database
    metadata = CSV.read(csv_path, {headers: true, header_converters: :symbol,
      encoding: "ISO-8859-1"})
    metadata.each_with_index do |photo_data, i|
      # TODO: Add a logger
      puts "[#{i} / #{metadata.count}] #{photo_data[:accession_]}"
      
      next if database.include? accession_number: photo_data[:accession_number],
        dvd: photo_data[:dvd]
     
      database.insert(
        accession_number: photo_data[:accession_master],
        accession_master: photo_data[:accession_],
        date_created: normalize_date(photo_data[:date_photographed]),
        dvd: photo_data[:dvd],
        source: photo_data[:source] 
      )
    end
  end

  def normalize_date date
    return nil if date.nil?

    date += "-01" if date =~ /^\d{4}-\d{2}$/

    begin
      DateTime.parse(date).strftime("%Y-%m-%d %H:%M:%S")
    rescue ArgumentError
      nil
    end
  end
end

class FileNotFoundError < RuntimeError
end

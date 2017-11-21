require 'csv'
require 'sequel'

class PhotostudioProcessor
  attr_accessor :csv_path

  def initialize csv
    if File.exists? csv
      self.csv_path = csv
    else
      raise FileNotFoundError.new("Could not locate #{csv}")
    end
  end

  def import_to database
    database = Sequel.sqlite(database: database)
    require 'database_record'

    metadata = CSV.read(csv_path, {headers: true, header_converters: :symbol,
      encoding: "ISO-8859-1"})
    metadata.each_with_index do |csv, i|
      puts "[#{i} / #{metadata.count}] #{csv[:accession_]}"
     
      DatabaseRecord.update_or_create({ 
        accession_master: csv[:accession_], 
        dvd: csv[:dvd] 
      }, { 
        accession_number: csv[:accession_master],
        date_created: normalize_date(csv[:date_photographed]),
        source: csv[:source] 
      }) 
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

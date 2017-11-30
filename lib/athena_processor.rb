require 'csv'
require 'sequel'

class AthenaProcessor
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
    require 'athena_record'

    metadata = CSV.read(csv_path, {headers: false, encoding: "ISO-8859-1"})
    metadata.each_with_index do |csv, i|
      puts "[#{i} / #{metadata.count}] #{csv[1]}"
     
      AthenaRecord.update_or_create({ 
        accession_number: csv[1], 
      }, { 
        accession_number: csv[1],
        category: csv[2] 
      }) 
    end
  end
end

class FileNotFoundError < RuntimeError
end

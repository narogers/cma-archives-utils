#!/usr/bin/env ruby
#
# import-accession-numbers.rb
# 
# Takes a data dump from Athena and converts into a reusable lookup table
# for other scripts to use when doing validation agasint currently active
# accession numbers. To use the results include the libraries 'sequel' and
# 'sqlite3' 
#
# To run the import execute
# bin/import-accession-numbers.rb [csv] [database]
#
# where 
# [csv] corresponds to a comma delimited list of keys, numbers, and types
# [database] corresponds to a stateless SQLite file on disk
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'athena_processor'
require 'sequel'

def initialize_database db
  @database = Sequel.sqlite(database: db)
  @database.create_table? :accessions do
    primary_key :id
    String :accession_number
    String :category
  end
end

csv_input = ARGV[0]
db_output = ARGV[1].nil? ? "accession_numbers.db" : ARGV[1]

initialize_database db_output
processor = AthenaProcessor.new csv_input
processor.import_to @database[:accessions]

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
# bin/import-accession-numbers.rb [csv] 
#
# The database is configured by setting the ATHENA_DB environment variable
# to a connection string. By default a database will be created in the working
# directory named accession_numbers.db
#
# where 
# [csv] corresponds to a comma delimited list of keys, numbers, and types
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'sequel'

def initialize_database
  uri = ENV.fetch("ATHENA_DB", "sqlite://accession_numbers.db") 
  database = Sequel.connect(uri)
  database.create_table? :accessions do
    primary_key :id
    String :accession_number
    String :category
  end
end

csv_input = ARGV[0]

initialize_database
require 'athena_processor'
processor = AthenaProcessor.new csv_input
processor.import

#!/usr/bin/env ruby
#
# import_photostudio_data
#
# Provide a CSV formatted document from the Photostudio containing accession
# numbers, camera sources, and dates photographed by converting from the 
# monthly XLS spreadsheet. This is then used downstream to insert additional
# metadata into Object Photography records when the manifests are created
# 
# Usage instructions
# %> import_photostudio_data [path to CSV] [photostudio.db]
# 
# An optional parameter will import to the specified SQLite database. If not
# present it will default to photostudio.db
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'photostudio_csv'
require 'sequel'

def initialize_database db_path
  @database = Sequel.sqlite(database: db_path)
  @database.create_table? :sources do
    primary_key :id
    String :accession_master
    String :accession_number
    String :dvd
    DateTime :date_created
    String :source
  end  
end

csv_path = ARGV[0]
db_path = ARGV[1].nil? ? "photostudio.db" : ARGV[1]

initialize_database db_path
processor = PhotostudioProcessor.new csv_path
processor.import_to @database[:sources]

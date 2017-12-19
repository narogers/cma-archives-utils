#!/usr/bin/env ruby
#
# prepareObjectBatch.rb
# 
# Run this script on a set of directories to create a metadata 
# template that is used during the batch ingest rake task. 
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'conservation_batch'

dropbox = ARGV[0]
subdirectories = Dir.glob(File.expand_path(dropbox) + "/**/")

subdirectories.each do |path|
  conservation_batch = ConservationBatch.new
  conservation_batch.process path if conservation_batch.process_directory? path
  conservation_batch.manifest "#{path}#{File::Separator}batch.csv" if conservation_batch.has_files?
end


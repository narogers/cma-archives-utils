#!/usr/bin/env ruby
#
# prepareObjectBatch.rb
# 
# Run this script on a set of directories to create a metadata 
# template that is used during the batch ingest rake task. 
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'object_photography_batch'

dropbox = ARGV[0]
batches = Dir.glob(File.expand_path(dropbox) + "/**/").select do |path|
  path.split("/").last 
end
batches.each do |batch|
  object_batch = ObjectPhotographyBatch.new
  object_batch.process batch
  object_batch.manifest "#{batch}#{File::Separator}batch.csv" if object_batch.has_files?
end


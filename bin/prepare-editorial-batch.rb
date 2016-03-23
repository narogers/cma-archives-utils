#!/usr/bin/env ruby
#
# prepareIngest.rb
# 
# Run this script on a set of directories to create a metadata 
# template that is used during the batch ingest rake task. 
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"));
require 'editorial_batch';

dropbox = ARGV[0]
batches = Dir.glob(File.expand_path(dropbox) + "/**/").select do |path|
  path.split("/").last =~ /^\d{4}-\d{2}.?\d{2}?\s+/
end
batches.each do |batch|
  editorial_batch = EditorialBatch.new
  editorial_batch.process batch
  editorial_batch.manifest "#{batch}#{File::Separator}batch.csv" if editorial_batch.has_files?
end


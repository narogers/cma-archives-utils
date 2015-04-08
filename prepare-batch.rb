#!/usr/bin/env ruby
#
# prepareIngest.rb
# 
# Run this script on a set of directories to create a metadata 
# template that is used during the batch ingest rake task. This is
# mostly meant to handle the images that lack any substantial 
# metadata but could be adopted for use in other situations
require 'csv'
require 'find'
require 'mime-types'
require 'pry'

base_directory = ARGV[0]
creator = ARGV[1]
# A safeguard to make sure even when no defaults are provided it
# does not default to nil
default_collections = ARGV.slice(2, ARGV.length - 2) || []

# Since RAW files are still problematic without a patch to MIME::Types do this
# the old fashioned way - by file extensions
formats = ['.dng', '.jpg', '.tif', '.tiff']

# Now begin to iterate over the directories and write out a
# simple batch file for each. Because of some edges cases the regular
# expression requires tweaking to handle
#
# = signs
# Dates that do not follow xxxx-xx-xx format
batches = Dir.glob(File.expand_path(base_directory) + '/**/').select { |f| f.split("/").last =~ /^\d{4}-\d{2}?\d{2}?/ }
batches.each do |batch|
	# Break up the title and cherry pick only the part that is needed
	# for the batch title and collection membership
	
	title = /\d{2}\s(.*)$/.match(batch.split("/").last)[1]
  images = []
  Find.find(batch) do |path|
  	next if File::directory?(path)
  	images.push(path) if (formats.include?(File::extname(path)))
  end

  # Write out the files with a header row, an empty line, and then
  # a filename followed by the metadata for that particular entry.
  #
  # There is no need to add the batch title which will automatically
  # be appended to the relationships for everything in the batch
  puts "Generating CSV template for \"#{title}\" at " + File::join([batch, "batch.csv"])
	CSV.open(File.join([batch, "batch.csv"]), "wb") do |c|
		c << [title, creator]
		c << []
		c << ['file', 'part_of']
		images.each do |i|
			c << [i, default_collections.join("|")]
		end
	end
end



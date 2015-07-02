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
creator = ARGV[1] || "clio-batches"
# A safeguard to make sure even when no defaults are provided it
# does not default to nil
default_collections = ARGV.slice(2, ARGV.length - 2) || []

# Since RAW files are still problematic without a patch to MIME::Types do this
# the old fashioned way - by file extensions
formats = ['.dng', '.jpg', '.jpeg', '.tif', '.tiff']

# Now begin to iterate over the directories and write out a
# simple batch file for each. Because of some edges cases the regular
# expression requires tweaking to handle
#
# = signs
# Dates that do not follow xxxx-xx-xx format
batches = Dir.glob(File.expand_path(base_directory) + '/**/').select { |f| f.split("/").last =~ /^\d{4}-\d{2}.?\d{2}?\s/ }
batches.each do |batch|
	# Break up the title and cherry pick only the part that is needed
	# for the batch title and collection membership
	
	title = /\d{2}\s([A-Z]{2}\s)?(.*)/.match(batch.split("/").last)
		.to_a.last
        # If present lop off the trailing digits unless they correspond
        # to a Gallery Number. To be safe unless remove '01', '1', etc
        # instead of any arbitrary string of digits
        title.gsub!(/\s[01]\d$/, "") 	
  images = []
  Find.find(batch) do |path|
  	next if File::directory?(path)
        # Trim the path back to be relative to the batch directory (ie subdir/01.tif or 04.dng)
        filename = path.gsub(batch, "")
        # Ignore dot files
        next if filename.match(/^\./)
  	images.push(filename) if (formats.include?(File::extname(path).downcase))
  end

  # Write out the files with a header row, an empty line, and then
  # a filename followed by the metadata for that particular entry.
  #
  # There is no need to add the batch title which will automatically
  # be appended to the relationships for everything in the batch
  puts "Generating CSV template for \"#{title}\" at " + File::join([batch, "batch.csv"])
	CSV.open(File.join([batch, "batch.csv"]), "wb") do |c|
		c << [title]
		c << [creator]
		default_collections.map do |coll|
			c << coll
		end
		c << []
		c << ['file']
		images.each do |i|
			c << [i]
		end
	end
end



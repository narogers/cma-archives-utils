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
require 'active_support/core_ext/string/inflections'

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
    # Now normalize the case since people may not have been consistent
    # in their naming practices
    title = title.titleize
  images = []
  Find.find(batch) do |path|
  	next if File::directory?(path)

    # Trim the path back to be relative to the batch directory (ie subdir/01.tif or 04.dng)
    filename = path.gsub(batch, "")
    # Skip dot files
    next if filename.match(/^\./)

    # Otherwise continue on
    source = path.gsub(base_directory, "")
    image_title = source.sub(/#{File::SEPARATOR}#{filename}$/, " - #{filename}")

    metadata = {file: filename, source: source, title: image_title}
    
    # TODO: Get this working once the model is refined
    #match_data = source.match(/^ED\s?(\d+)/)
    #metadata[:ispartof] = match_data.nil? ? nil : "DVD ##{match_data[1]}"

  	images.push(metadata) if (formats.include?(File::extname(path).downcase))
  end

  # Write out the files with a header row, an empty line, and then
  # a filename followed by the metadata for that particular entry.
  #
  # There is no need to add the batch title which will automatically
  # be appended to the relationships for everything in the batch
  puts "Generating CSV template for \"#{title}\" at " + File::join([batch, "batch.csv"])
    # :file always goes first but the order of the rest of the fields matters much
    # less. Therefore we delete it before pushing it to the first spot in the
    # array
    metadata_fields = images.first.keys
    metadata_fields.delete(:file)
    metadata_fields.unshift(:file)

	CSV.open(File.join([batch, "batch.csv"]), "wb") do |c|
		c << [title]
		c << [creator]
		default_collections.each do |coll|
			c << [coll]
		end
		c << []
		c << metadata_fields
		images.each do |i|
			c << metadata_fields.map { |field| i[field] }
		end
	end
end



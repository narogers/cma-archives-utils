#!/usr/bin/env ruby
# Given a CSV export of collections with metadata mappings the script's intent is to
# normalize the name then export the file again for handling by various rake tasks
require 'csv'

def run()
  source = ARGV[0]

  input = load_file(source)
  collections = normalize_source(input)
  export_csv(collections, output_file(source))
end

def load_file(path)
  if (not File.exists? path and
     ".csv" == File.extname)
     print "WARNING: Cannot process #{path}\n"
     print "Terminating script"
     exit(1)
  end

  # Otherwise proceed with ingest
  print "Loading #{path} ...\n"
  CSV.read(path, encoding: "UTF-8", headers: true, header_converters: :symbol)
end

def normalize_source(csv_data)
  collections = []

  csv_data.each do |row|
    row[:name] = normalize_name(row[:name])
    row[:category] = normalize_category(row[:category])
    collections << row
  end
end

def normalize_name(collection_name)
  collection_name.gsub!("_", " ")
  # Strip off leading dates
  collection_name.gsub!(/^\d{4}-\d{2}(-\d{2})?\s*/, "")
  # Strip off photography credits as well
  collection_name.gsub!(/^(BM|DB|FM|GD|HA|PB|RM)\s?/, "")
  collection_name = collection_name.titleize
  
  return collection_name
end

# This is much easier as all that is required to strip whitespace
def normalize_category(category)
  category.gsub!("_", "")

  return category
end

def export_csv(collections, path)
  if File.exists? path
    print "WARNING: About to overwrite #{path}\n"
  end

  header = collections.first.to_h.keys.sort
  # The collection name should always come first regardless of what metadata is the rest
  # of the file so cut it from the list then reorder things
  header.delete(:name)
  header = [:name] + header

  CSV.open(path, "wb") do |csv|
    csv << header
    collections.each_with_index do |coll, i|
      print "[#{i} of #{collections.length}] Exporting #{coll[:name]}\n"
      row = []
      header.each do |key|
        row << coll[key]
      end
      csv << row
    end   
  end
end

def output_file(path)
    full_path = File.expand_path(path)
    directory = File.dirname(full_path)
    file_name = File.basename(full_path, ".*")
    extension = File.extname(full_path)

    return "#{directory}#{File::SEPARATOR}#{file_name}-normalized#{extension}"  
end

# Now kick off the script
run

#!/usr/bin/env ruby
#
# analze-conservation-files.rb
#
# Normalizes and extracts metadata into a CSV report for further analysis
# by archivists and stakeholders
#
# To use
# ./analyze-conservation-files.rb --path=[root path to staging]
$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'csv'
require 'optparse'
require 'conservation_codes'

def normalize(path)
  path.gsub!(" ","_") 
  parts = path.split("_") 
  if (parts[0].match(/^\d{2,}$/) and
      parts[1].match(/^\d+$/))
    accession_number = parts.shift
    accession_number = parts.shift
    parts[0] = "#{accession_number}.#{parts[0]}" 
  end
  
  return parts.join("_")
end

def parsePath(path)
  metadata = {}
  parts = path.split("_")
  title = []
 
  if parts[0].match(/^\d{2,}\.\d+/)
    metadata[:object] = parts.shift
  end
  
  metadata[:codes] = {}
  
  parts.each_with_index do |code, i|
    if Conservation::SHORT_CODES[code.to_sym].nil?
      title << code
    else
      expanded_field = Conservation::SHORT_CODES[code.to_sym]
      metadata[:codes][expanded_field[1]] ||= []
      metadata[:codes][expanded_field[1]] << "#{expanded_field[0]} (#{code})"
    end
  end
  metadata[:title] = title.join(" ")
  
  return metadata
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: analyze-conservation-files.rb [options]"
  opts.on("-p", "--path PATH", "Path to staged files") do |path|
    options[:path] = path
  end
end.parse!

directories = [] 
files = [] 

puts "Processing #{options[:path]}"

Dir["#{options[:path]}/**/*"].each do |full_path|
  normalized_path = full_path.sub(options[:path], "")
  normalized_path = normalize(normalized_path)

  directories << normalized_path if File.directory?(full_path)
  files << normalized_path if File.file?(full_path)
end

directory_report = CSV.open("conservation-directories.csv", "w")
headers = ["Path", "Accession Number", "Title"]
Conservation::FIELDS.each { |f| headers << f.to_s }
directory_report << headers

# Start with directories
directories.each do |dirname|
  paths = dirname.split("/") 
  paths.shift 
  
  details = [dirname]
  
  metadata = {
    codes: 
      { division: [paths.shift.split("_").join(" ")]
    }
  } 

  while not paths.empty?
    segment = paths.shift
    properties = parsePath(segment) 
   
    if (not properties[:object].nil?)
      metadata[:object] = properties[:object]
      metadata[:title] = properties[:title] if metadata[:title].nil?

      properties[:codes].each do |field, value|
        metadata[:codes][field] ||= []
        metadata[:codes][field] += value
        metadata[:codes][field].uniq!
      end
    end
  end
  
  details << metadata[:object]
  details << metadata[:title]

  Conservation::FIELDS.each do |k| 
    if metadata[:codes][k].nil?
      details << ""
    else
      details << metadata[:codes][k].join(" | ") 
    end
  end

  directory_report << details
end
directory_report.close()

# Now process files
file_report = CSV.open("conservation-files.csv", "w")
headers = ["Path", "Accession Number", "Title"]
Conservation::FIELDS.each { |f| headers << f.to_s }
file_report << headers

files.each do |path|
  details = [path]
  department = path.split("/")[1].gsub("_", " ")

  file_name = File.basename(path)
  metadata = parsePath(File.basename(file_name, File.extname(file_name)))
 
  details << (metadata[:object].nil? ? "" : metadata[:object])
  details << file_name
  metadata[:codes][:division] = [department]

  Conservation::FIELDS.each do |field|
    value = metadata[:codes][field].nil? ?
      "" : metadata[:codes][field].join(" | ")
    details << value
  end
  file_report << details
end
file_report.close()

#!/usr/bin/env ruby
#
# analze-conservation-files.rb
#
# Normalizes and extracts metadata into a CSV report for further analysis
# by archivists and stakeholders
#
# To use
# ./analyze-conservation-files.rb [root path to staging]
require 'csv'
require 'optparse'
require 'pry'

SHORT_CODES = {
  CT: "Conservation Treatment",
  CL: "Conservation Loan",
  CR: "Conservation Research",
  CI: "Conservation Installation",
  CA: "Conservation Analysis",
  CE: "Conservation Acquisition",
  CX: "Conservation Examination",
  CER: "Conservation External Research",
  APP: "Apparatus",
  FR: "Frame",
  BT: "Before Treatment",
  DT: "During Treatment",
  AT: "After Treatment",
  SP: "Sample",
  BS: "Before Sample",
  AS: "After Sample",
  REC: "Recto",
  VER: "Verso",
  TOP: "Top",
  BOT: "Bottom",
  FNT: "Front",
  BCK: "Back",
  LFT: "Left side of an object",
  RGT: "Right side of an object",
  INT: "Interior shot of an object",
  EXT: "Exterior shot of an object",
  # DEG_xxx: "Degree",
  # DETxx: "Detail XX",
  # SECxx: "Section XX",
  DIA: "Diagram",
  HEAD: "Head (book)",
  SPINE: "Spine (book)",
  TAIL: "Tail (book)",
  FOREEDGE: "Fore edge (book)",
  # PGxx: "Page XX",
  NL: "Normal light",
  RL: "Raking light",
  TL: "Transmitted light",
  SL: "Specular light",
  OSL: "Oblique Specular Light",
  UV: "Ultra Violet fluoresence",
  IR: "Infrared Reflectography",
  XR: "X-Ray",
  RF: "Reflected",
  FCUV: "False Color Ultraviolet",
  FCIR: "False Color Infrared"
}

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
  
  if parts[0].match(/^\d{2,}\.\d+/)
    metadata[:object] = parts.shift
  end
  
  metadata[:codes] = [] 
  parts.each do |code|
	break if SHORT_CODES[code.to_sym].nil?
	
	code = parts.shift
	metadata[:codes] << "#{SHORT_CODES[code.to_sym]} (#{code})"
  end
  
  metadata[:title] = parts.join(" ")
  
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

report = CSV.open("conservation-report.csv", "w+")
report << ["Path", "Type", "Department", "Accession Number", "Title", "Codes"]

# Start with directories
directories.each do |dirname|
  paths = dirname.split("/") 
  paths.shift 
  
  details = [dirname, "directory"]
  details << paths.shift.split("_").join(" ") 

  while not paths.empty?
    segment = paths.shift
    metadata = parsePath(segment) 
    
    if (not metadata[:object].nil?)
     details << metadata[:object]
     details << metadata[:title]
     details << metadata[:codes].join("|")
     break
    end
  end
  
  report << details
end

# Now process files
files.each do |path|
  details = [path, "file"]

  file_name = File.basename(path)
  metadata = parsePath(file_name)

  details << (metadata[:object].nil? ? "" : metadata[:object])
  details << file_name
  details << metadata[:codes].join("|")

  report << details
end

report.close()

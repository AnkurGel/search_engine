require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'webrobots'
require 'fast-stemmer'
#require 'debugger'
require 'wirb'
require 'awesome_print'
require 'logger'
require 'data_mapper'
require_relative 'models.rb'

#Configuring seed file
SEED = File.join(Dir.pwd, 'seeds.yaml')

#Configuring database
DataMapper.setup(:default, "sqlite:///#{File.join(Dir.pwd, 'data.db')}")

#Initializing logger
logger = Logger.new STDOUT
logger.level = Logger::WARN

RESTRICTED_TYPES = %w(.pdf .doc .docx .xls .xlsx .ppt .pptx .json .mpg .mpeg .avi .wmv .xml .mp3 .m4a .jpg .gif .png .bmp .zip .rar .7z .asc)

# Sanitizes a URL
def sanitize(site)
  url = URI(site)
  begin
    url = URI::HTTP.build({ host: url.to_s }) if url.instance_of? URI::Generic 
  rescue URI::InvalidComponentError => e
    logger.warn("#{site} is not a valid URL.")
  end
  return url.to_s
end

class URI::InvalidURL < Exception; end


#Traverse the seeds and start crawling ...
YAML.load(File.open(SEED)).each do |site|
  begin
    site = sanitize(site)
  rescue
    next
  end
  puts "Found #{site} <-- Crawling ..."
  begin
  doc = Nokogiri::HTML(open(site))
  links = doc.css('a').map do |link|
    if link['href']
      link = link['href']
      link = URI.join(site, link).to_s if link.start_with?("/")
      link.to_s
    else nil
    end
  end.uniq.compact
  p links
  rescue OpenURI::HTTPError => e
    puts "Couldn't connect - #{e.message}"
  rescue Timeout::Error => e
    puts "Request timed out! - #{e.message}"
  rescue Exception => e
    puts "Something went wrong - #{e.inspect} - #{e.message}"
  end
end



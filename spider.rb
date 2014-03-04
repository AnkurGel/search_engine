require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'logger'
require 'data_mapper'

#Configuring seed file
SEED = File.join(Dir.pwd, 'seeds.yaml')

#Configuring database
DataMapper.setup(:default, "sqlite:///#{File.join(Dir.pwd, 'data.db')}")

# Sanitizes a URL
def sanitize(site)
  url = URI(site)
  begin
  url = URI::HTTP.build({host: url.to_s}) if url.instance_of? URI::Generic 
  rescue URI::InvalidComponentError => e

  end

  return url.to_s
end
class URI::InvalidURL < Exception; end

class String
  def valid_url?
    true
  end
end

Psych.load(File.open(SEED)).each do |site|
  next unless site.valid_url?
  site = sanitize(site)
  puts "Found #{site} <-- Crawling ..."
  begin
  doc = Nokogiri::HTML(open(site))
  links = doc.css('a').map do |link|
    if link['href']
      URI.parse(site, link['href']).to_s if link['href'].to_s.start_with?("/")
    else
      link['href'].to_s
    end
  end.uniq
  p links
  rescue OpenURI::HTTPError => e
    puts "Couldn't connect - #{e.message}"
  rescue Timeout::Error => e
    puts "Request timed out! - #{e.message}"
  rescue Exception => e
    puts "Something went wrong - #{e.message}"
  end
end



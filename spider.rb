require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'webrobots'
require 'fast-stemmer'
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


# Sanitizes a URL by making it validate across `URI` class.
#  makes sure that object has correct URI host(http/https) so that it can
#  be requested correctly with `open-uri`
#
# @param site [String] the site to be parsed
# @return [String] the properly structured URL(with URI host)
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

robots = WebRobots.new('AnkurBot/1.0')


# @param link [String] contains the URL to be scrubbed
# @return [String, nil] the object contains the scrubbed URL(free from anchor)
#   or nil if it has restricted MIME or invalid structure.
def scrub(link)
  unless link.nil?
    link = link.scan(/.*(?=#)/)[0] if link.match(/#/)
    return nil if RESTRICTED_TYPES.include? File.extname(link)
    URI.join(URI.escape(link)).normalize.to_s
  end
end

COMMON_WORDS = File.read('common_words').split("\n")

# Performs indexing.
#  Finds words --> Removes `COMMON_WORDS` --> Stems remaining
#  --> sets association b/w the word and it's location in page
#  Writes words, locations and link to database.
#
# @param url [String] the object containing the URL of site being indexed
# @param doc [Nokogiri::HTML::Document] the document nodes from which body etc can be extracted
# @return [Link] the object which is indexed
def add_to_index(url, doc)
  # Indexing
  link = Link.first_or_new(url: url)
  if link.indexable?
    puts "  Indexing #{url} at #{Time.now} <--"
    #doc = Nokogiri::HTML(open(url))
    link.locations.destroy unless link.new?
    body = doc.at('body')
    title = doc.at('title')
    body.search('script, noscript').remove
    words = body.text.gsub(/[\d]|[^\w\s]/, '').split.map(&:downcase).reject do |word|
      COMMON_WORDS.include?(word) or word.size > 25
    end.map(&:stem).each_with_index do |word, index|
      loc = Location.new(position: index)
      loc.word = Word.first_or_new(stem: word)
      loc.link = link
      puts "    --> Writing word - #{word} at index #{index}"
      loc.save
    end
    puts "    --> Writing title - #{title.text}"
    link.title = title.text
    link.indexed = true
    link.save
    link
  else
    #return link without modification
    link
  end
end


#Traverse the seeds and start crawling ...
loop do
  accumulated_links = []
  YAML.load(File.open(SEED)).map do |site|
    begin
      site = scrub(sanitize(site))
    rescue
      next
    end
    puts "Found the #{site} <-- Initializing procedure ..."
    link = Link.first_or_new(url: site)
    if link.new? or link.indexable?
      begin
        #if link.new? or link.indexable?
        doc = Nokogiri::HTML(open(site))
        current_link = add_to_index(site, doc)
        links = []
        puts "  Now crawling the #{site} for further links... <--"
        doc.css('a').each do |link|
          if link['href']
            begin
              link = link['href']
              link = URI.join(site, link).to_s if link.start_with? "/"
              link = scrub(link)
              #link = scrub(URI.join(site, link).to_s) if link.start_with?("/")
              link ? (robots.allowed?(URI(link)) ? link : nil) : link

              #TODO: Don't do below, if link is linking itself
              if link
                processed_link = Link.first_or_create(url: link)

                if !current_link.outbounds.include?(processed_link) and (current_link != processed_link)
                  current_link.outbounds << processed_link unless current_link.outbounds.include?(processed_link)
                  links << link
                end
              end
              #accumulated_links << link

              puts " -> #{link}"
            rescue Exception => e
              puts "Something went wrong in here - #{e.message}"
              nil
            end
          end
        end
        #Saving number of outbound links C(t) for PageRank algorithm
        links = links.uniq.compact
        current_link.total_outbound_links = links.count
        current_link.save
        accumulated_links << links

      rescue OpenURI::HTTPError => e
        puts "Couldn't connect - #{e.message}"
      rescue Timeout::Error => e
        puts "Request timed out! - #{e.message}"
      rescue Exception => e
        puts "Something went wrong - #{e.inspect} - #{e.message}"
      end

    else
      puts "  --> #{site} is already indexed recently. Skipping to next ..."
    end
  end
  accumulated_links = accumulated_links.flatten.uniq.compact

  File.open(SEED, 'wb') do |file|
    file.puts("---")
    accumulated_links.each { |link| file.puts "- #{link}" }
  end

end

require 'rubygems'
require 'bundler/setup'

require 'data_mapper'

#Configuring database
DataMapper.setup(:default, "sqlite:///#{File.join(Dir.pwd, 'data.db')}")

INDEX_POLICY = 3 * 24 * 60

class Relation
  include DataMapper::Resource

  belongs_to :source, 'Link', key: true
  belongs_to :target, 'Link', key: true
end

class Link
  include DataMapper::Resource

  property :id, Serial
  property :url, String, length: 255
  property :title, String, length: 255
  property :total_outbound_links, Integer#, default: 0
  property :rank, Float, default: 1.0
  property :indexed, Boolean, default: false
  property :created_at, DateTime, default: lambda { |r, p| 
    Time.now.to_datetime
  }
  property :updated_at, DateTime, default: lambda { |r, p|
    Time.now.to_datetime
  }

  has n, :locations
  has n, :words, through: :locations

  # Self-referential relationship:
  # A Link can have many outbound_links (which are Link objects)
  has n, :relations, child_key: [ :source_id ]
  has n, :outbounds, self, through: :relations, via: :target

  # Reverse relationship for inbound_links
  has n, :reverse_relations, 'Relation', child_key: [ :target_id ]
  has n, :inbounds, self, through: :reverse_relations, via: :source

  def age
    (Time.now - updated_at.to_time) / 60
  end

  def indexable?
    if new? or not indexed
      true
    else
      age > INDEX_POLICY ? true : false
    end
  end
end

class Word
  include DataMapper::Resource

  property :id, Serial
  property :stem, String

  has n, :locations
  has n, :links, through: :locations
end

class Location
  include DataMapper::Resource

  property :id, Serial
  property :position, Integer

  belongs_to :word
  belongs_to :link
end

DataMapper.finalize
DataMapper.auto_upgrade!

require 'rubygems'
require 'bundler/setup'

require 'data_mapper'

#Configuring database
DataMapper.setup(:default, "sqlite:///#{File.join(Dir.pwd, 'data.db')}")

INDEX_POLICY = 3 * 24 * 60

class Link
  include DataMapper::Resource

  property :id, Serial
  property :url, String, length: 255
  property :title, String, length: 255
  property :created_at, DateTime, default: lambda { |r, p| 
    Time.now.to_datetime
  }
  property :updated_at, DateTime, default: lambda { |r, p|
    Time.now.to_datetime
  }

  has n, :locations
  has n, :words, through: :locations

  def age
    (Time.now - updated_at.to_time) / 60
  end

  def indexable?
    if new? 
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

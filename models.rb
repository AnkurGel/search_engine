require 'rubygems'
require 'bundler/setup'

require 'data_mapper'

#Configuring database
DataMapper.setup(:default, "sqlite:///#{File.join(Dir.pwd, 'data.db')}")

class Link
  include DataMapper::Resource

  property :id, Serial
  property :url, String, length: 255
  property :created_at, DateTime, default: lambda { |r, p| 
    Time.now.to_datetime
  }
  property :updated_at, DateTime, default: lambda { |r, p|
    Time.now.to_datetime
  }

  def age
    (Time.now - updated_at.to_time) / 60
  end
end

DataMapper.finalize
DataMapper.auto_migrate!

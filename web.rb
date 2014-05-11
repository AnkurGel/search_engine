require 'sinatra'
require 'json'
require 'haml'
require './seeker'

get '/' do
  haml :index
end

post '/search' do
  engine = SearchEngine::Query.new
  @results = SearchEngine::Query.new.search(params[:query])

  @frequency = engine.search(params[:query], :frequency)
  @location = engine.search(params[:query], :location)
  @distance = engine.search(params[:query], :distance)
  @pagerank = engine.search(params[:query], :pagerank)

  haml :index
end

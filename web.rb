require 'sinatra'
require 'json'
require 'haml'
require './seeker'

get '/' do
  haml :index
end

post '/search' do
  engine = SearchEngine::Query.new
  begin

    @search_words = params[:query]
    @results = SearchEngine::Query.new.search(@search_words)

    @frequency = engine.search(@search_words, :frequency)
    @location = engine.search(@search_words, :location)
    @distance = engine.search(@search_words, :distance)
    @pagerank = engine.search(@search_words, :pagerank)
  rescue Exception => e
    @search_words = params[:query]
    haml :error
  else

    haml :index
  end



end

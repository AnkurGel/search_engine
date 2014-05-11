require 'sinatra'
require 'haml'
require './seeker'

get '/' do
  haml :index
end

post '/search' do
  @results = search(params[:query])
  haml :index
end

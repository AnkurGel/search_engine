require 'sinatra'
require 'haml'
require './seeker'
require 'debugger'

get '/' do
  haml :index
end

post '/search' do
  @results = search(params[:query])
  haml :index
end

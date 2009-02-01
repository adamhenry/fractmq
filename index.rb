require 'rubygems'
require 'sinatra'
require 'rush'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'

get '/' do
  Snowflake.new.draw
  erb :index
end

get '/restart' do
  Rush::Box[ Dir.pwd ]['public/snowsnowflake*.png'].destroy
  redirect '/'
end


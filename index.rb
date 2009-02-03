require 'rubygems'
require 'sinatra'
require 'rush'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'

get '/' do
  erb :index
end

get '/start' do
  params ||= {}
  Rush::Box.new[ Dir.pwd + '/']['public/snowflake*.png'].each { |f| f.destroy }
  Snowflake.generate(params)
  redirect '/'
end


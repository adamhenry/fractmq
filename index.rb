require 'rubygems'
require 'sinatra'
require 'rush'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'

get '/' do
  erb :index
end

post '/start' do
  Rush::Box.new[ Dir.pwd + '/']['public/snowflake*.png'].each { |f| f.destroy }
  Snowflake.new.draw_each_piece
  #Snowflake.generate(params)
  redirect '/'
end


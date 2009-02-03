require 'rubygems'
require 'sinatra'

$LOAD_PATH << File.dirname(__FILE__)

require 'lib/fractalmq'

get '/' do
  redirect '/display'
end

get '/display' do
  params["side"] = ( params["side"] ||= 3 ).to_i
  erb :index
end

post '/start' do
  params["side"] = ( params["side"] ||= 3 ).to_i
  pwd[FractMQ.base_file_name + '*.png'].each { |f| f.destroy }
  FractMQ.generate(params)
  redirect '/display?side=' + params["side"].to_s
end

helpers do
  def part_file_name j, i
    file_name = "#{FractMQ.base_file_name}#{j}.#{params["side"]-(i+1)}.png"
    file_name = "blank.png" unless File.exists?(FractMQ.dir + file_name)
    file_name
  end
  
  def option_nxn n
    selected = "selected=\"selected\" " if params["side"] == n
    "<option value=\"#{n}\" #{selected}>#{n}x#{n}</option>"
  end
end


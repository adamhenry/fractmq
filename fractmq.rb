require 'rubygems'
require 'sinatra'

$LOAD_PATH << File.dirname(__FILE__)

require 'lib/fractalmq'

[ '/', '/:side/?' ].each do |path|
  get path do
    params["side"] = ( params["side"] ||= 3 ).to_i
    erb :index
  end
end

get '/start/:side' do
  params["side"] = ( params["side"] ||= 3 ).to_i
  pwd[FractMQ.base_file_name + '*.png'].each { |f| f.destroy }
  FractMQ.generate(params)
  redirect '/' + params["side"].to_s
end

helpers do
  def part_file_name j, i
    file_name = "#{FractMQ.base_file_name}#{j}.#{params["side"]-(i+1)}.png"
    file_name = "blank.png" unless File.exists?(FractMQ.dir + file_name)
    file_name
  end
end


require 'rubygems'
require 'sinatra'

$LOAD_PATH << File.dirname(__FILE__)

require 'lib/fractmq'

[ '/', '/:side/?' ].each do |path|
  get path do
    params["side"] = ( params["side"] ||= 3 ).to_i
    erb :index
  end
end

get '/start/:side' do
  params["side"] = ( params["side"] ||= 3 ).to_i
  pwd['public/snowflake*.png'].each { |f| f.destroy }
  Snowflake.generate(params)
  redirect '/' + params["side"].to_s
end


require 'rubygems'
require 'sinatra'
require 'rush'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'

[ '/', '/:side/?' ].each do |path|
  get path do
    params["side"] = ( params["side"] ||= 3 ).to_i
    erb :index
  end
end

get '/start/:side' do
  params["side"] = ( params["side"] ||= 3 ).to_i
  Rush::Box.new[ Dir.pwd + '/']['public/snowflake*.png'].each { |f| f.destroy }
  Snowflake.generate(params)
  redirect '/' + params["side"].to_s
end


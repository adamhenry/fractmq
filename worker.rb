require 'rubygems'
require 'mq'
require 'json'
require 'base64'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/fractmq'


EM.run do
  exchange = MQ.topic
  MQ.queue('draw fractal pieces').bind(exchange, :key => 'fractal.piece.draw' ).subscribe do |msg|
    EM.defer proc {
      msg = JSON.parse(msg)
      puts "Begin #{msg["piece"].to_json}"
      msg["png"] = Base64.encode64( FractMQ.new( msg ).draw_piece )
      puts "End #{msg["piece"].to_json}"
      exchange.publish(msg.to_json, :routing_key => 'fractal.piece' )
    }
  end
end

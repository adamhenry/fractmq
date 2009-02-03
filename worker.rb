require 'rubygems'
require 'mq'
require 'json'
require 'base64'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'


EM.run do
  exchange = MQ.topic('fractal')
  MQ.queue('draw fractal pieces').bind(exchange, :key => 'fractal.piece.draw' ).subscribe do |msg|
    msg = Snowflake.clean_json_hash JSON.parse(msg)
    print "Generating Piece #{msg[:piece].to_json} ...."
    STDOUT.flush()
    msg[:png] = Base64.encode64( Snowflake.new( msg ).draw_piece )
    puts " Done"
    STDOUT.flush()
    exchange.publish(msg.to_json, :routing_key => 'fractal.piece' )
  end
end

require 'rubygems'
require 'mq'
require 'json'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/snowflake'

snowflake = Snowflake.new

EM.run do
  MQ.topic('fractal')
  MQ.queue('fractal').bind('fractal').subscribe do |msg|
    puts msg
    snowflake.draw_piece JSON.parse(msg)
  end
end

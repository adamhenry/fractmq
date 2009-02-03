require 'base64'
require 'vender/lib/fractals'
require 'rush'
require 'json'
require 'mq'


class Snowflake
  include Fractals

  def initialize opt=nil
    opt = Snowflake.clean_json_hash( opt || {} )
    set_side( opt[:side] ||= 3 )
    set_defaults
    set_piece( opt[:piece] ||= [0,0] )
  end

  def self.clean_json_hash old_hash
    new_hash = {}
    old_hash.each_pair { |key, value| new_hash[key.to_sym] = value }
    new_hash
  end

  def self.generate params 
    snowflake = Snowflake.new( params[:side] )
    snowflake.start_queue
    EM.run { snowflake.each_tile { |tile| snowflake.publish_piece tile } }
  end

  def each_tile number=nil
    (number ||= @side).times { |i| number.times { |j| yield [i, j] } }
  end
  
  def start_queue
    path = Dir.pwd + '/'
    EM.run do
      if !MQ.queue('fractal rebuild').subscribed?
        MQ.queue('fractal rebuild').bind( 'fractal', :key => 'fractal.piece').subscribe do |msg|
          msg = JSON.parse(msg)
          data = msg.delete("png")
          file_name = Snowflake.new(msg).piece_name
          print "Writing >--  " + file_name
          STDOUT.flush()
          File.delete file_name if File.exists? file_name
          File.open( file_name, "w") { |file| file.print Base64.decode64(data) }
          puts " --<  Done"
          STDOUT.flush()
        end
      end
    end
  end

  def publish_piece p=nil
    set_piece p ||= @snowflake.piece
    unless File.exists?( piece_name )
      puts ("Publishing Fractal Segment Request: " + piece_name )
      msg = {}
      msg[:side] = @side
      msg[:piece] = p
      MQ.topic('fractal').publish(msg.to_json, :routing_key => 'fractal.piece.draw')
    end
  end

  def draw_piece p=nil
    set_piece ( p ||= @snowflake.piece ) 
    file_name = "/tmp/fracMQ.#{@side}.#{rand(999_999)}.#{p[0]}.#{p[1]}##{Process.pid}"
    @snowflake.draw( file_name )
    file = IO.read file_name
    File.delete(file_name)
    file
  end

  def piece_name p=nil
    p ||= @snowflake.piece
    "public/snowflake#{p[0]}.#{p[1]}.png"
  end
  
  def set_piece p
    raise "peice must be an Array <#{p.class}>" if p.class != Array 
    raise "peice must have a length of 2 <#{p.length}>" if p.length != 2 
    raise "peice[0] must be a Fixeum <#{p[0].class}>" if p[0].class != Fixnum 
    raise "peice[1] must be a Fixeum <#{p[1].class}>" if p[1].class != Fixnum 
    raise "peice[0] must be < #{@side} <#{p[0]}>" if p[0] >= @side 
    raise "peice[0] must be < #{@side} <#{p[0]}>" if p[1] >= @side 
    raise "peice[0] must be >= 0 <#{p[0]}>" if p[0] < 0 
    raise "peice[1] must be >= 0 <#{p[1]}>" if p[1] < 0 
    @snowflake.piece = p
  end

  def set_side side
    raise "side must be a Fixnum <#{side.inspect}>" unless side.is_a?(Fixnum)
    raise "side must be > 0 <#{side.inspect}>" unless side > 0
    @side = side
  end

  def set_defaults
    @snowflake = Julia.new(Complex(-0.3007, 0.6601), 5, 100)
    @snowflake.pieces = [ @side, @side ]
    @snowflake.width = 360
    @snowflake.height = 360
    @snowflake.m = 2
    @snowflake.set_color = PNG::Color::White
    @snowflake.algorithm = Algorithms::NormalizedIterationCount
    @snowflake.theme = lambda { |index|
      r, g, b = 0, 0, 0      
      if index >= 510
        r = 0
        g = 255 % index
        b = 255
      elsif index >= 255
        r = 0
        g = index % 255
        b = 255
      else    
        b = index % 255
      end      
      return r, g, b
    }
  end

end

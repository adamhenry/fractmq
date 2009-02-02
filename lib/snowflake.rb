require 'vender/lib/fractals'
require 'png'
require 'rubygems'
require 'rush'
require 'json'
require 'mq'

class Snowflake
  include Fractals

  def initialize side = 3
    @side = side
    set_defaults
      
    @x = []
    @side.times do |i|
      @side.times do |j|
        @x << [ i, j ]
      end
    end
  end

  def draw_each_piece
    @x.each do |p|
      publish_draw_piece p
    end
  end

  def publish_draw_piece p
    puts ("Publishing Fractal Segment Request: " + piece_name( p ) )
    puts "JSON:[#{@snowflakes.to_json}]"
    EM.run do
      MQ.topic('fractal').publish(p.to_json)
    end
  end

  def draw_piece p
    file = Rush::Box.new[Dir.pwd+'/'][piece_name(p)]
    if file.exists?
      puts ("File Exists: " + piece_name( p ) )
    else
      file.write('')
      puts ("Creating File: " + piece_name(p) )
      @snowflakes.piece = p
      @snowflakes.draw( piece_name(p) )
    end
  end

  def piece_name p
    raise "peice must be an Array <#{p.class}>" if p.class != Array 
    raise "peice must have a length of 2 <#{p.length}>" if p.length != 2 
    raise "peice[0] must be a Fixeum <#{p[0].class}>" if p[0].class != Fixnum 
    raise "peice[1] must be a Fixeum <#{p[1].class}>" if p[1].class != Fixnum 
    raise "peice[0] must be < #{@side} <#{p[0]}>" if p[0] >= @side 
    raise "peice[0] must be < #{@side} <#{p[0]}>" if p[1] >= @side 
    raise "peice[0] must be >= 0 <#{p[0]}>" if p[0] < 0 
    raise "peice[1] must be >= 0 <#{p[1]}>" if p[1] < 0 
    "public/snowflakes#{p[0]}.#{p[1]}.png"
  end
    
  
  def set_defaults
    @snowflakes = Julia.new(Complex(-0.3007, 0.6601), 5, 100)
    @snowflakes.pieces =  [ @side, @side ]
    @snowflakes.width = 360
    @snowflakes.height = 360
    @snowflakes.m = 2
    @snowflakes.set_color = PNG::Color::White
    @snowflakes.algorithm = Algorithms::NormalizedIterationCount
    @snowflakes.theme = lambda { |index|
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

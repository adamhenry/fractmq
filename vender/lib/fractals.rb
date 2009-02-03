# RB
#This is Ryan Baxter's fractal libary with a little piece of funtionality for my use -- Adam Henry
#the original file can be found at http://crunchlife.com/pages/ruby_fractal_library

require 'rubygems'
require 'complex'
require 'png'

module Fractals
  include Math 
  
  class Fractal    
    attr_accessor :z, :c, :width, :height, :m, :set_color, :algorithm, :theme, :piece, :pieces
    
    def initialize(c)      
      @c = c
      @width, @height, @m = 300, 300, 1.0 
      @set_color = PNG::Color::Black
      @algorithm = Algorithms::EscapeTime
      @theme = Themes::Fire        
    end
    
    def piece_height
      @height / pieces[1]
    end

    def piece_width
      @width / pieces[0]
    end

    def piece_width_offset
      piece_width * piece[0]
    end

    def piece_height_offset
      piece_height * piece[1]
    end

    def validate_pieces
      raise "pieces is not an array it is #{ pieces.class }" unless pieces.class == Array
      raise "piece is not an array it is #{ piece.class }" unless piece.class == Array
      raise "pieces is not 2 deep" unless pieces.size == 2
      raise "piece is not 2 deep" unless piece.size == 2
      raise "pieces less than zero" if pieces[0] < 0
      raise "pieces less than zero" if pieces[1] < 0
      raise "piece less than zero" if piece[0] < 0
      raise "piece less than zero" if piece[1] < 0
      raise "piece too large" if piece[0] >= pieces[0]
      raise "piece too large" if piece[1] >= pieces[1]
      raise "PNG width is not divisible by #{pieces[0]}" unless @width % pieces[0] == 0
      raise "PNG height is not divisible by #{pieces[1]}" unless @height % pieces[1] == 0
    end

    def draw(file_name='fractal.png')      
      validate_pieces
      canvas = PNG::Canvas.new(piece_width, piece_height)
      0.upto(piece_width - 1) { |x|
        0.upto(piece_height - 1) { |y|          
          if in_set?(where_is?(x + piece_width_offset, y + piece_height_offset)) then            
            canvas[x, y] = @set_color
          else            
            r, g, b = *@theme.call(@algorithm.call(self))
            canvas[x, y] = PNG::Color.new(r, g, b, 255)         
          end
        }
      }   
      png = PNG.new(canvas)
      png.save(file_name)
    end   
    
    def where_is?(x, y)
      r = @c.real - (@width / 2 * scale(@width)) + (x * scale(@width))
      i = @c.image - (@height / 2 * scale(@height)) + (y * scale(@height))      
      return Complex(r, i)
    end    
    
    private    
    def scale(length)
      return (0.01 / @m) * (300.0 / length)
    end   
  end

  class Julia < Fractal    
    attr_accessor :bailout, :last_iteration, :max_iterations
    
    def initialize(c=Complex(0.36, 0.1), bailout=2, max_iterations=50)    
      super(c)
      @bailout, @max_iterations = bailout, max_iterations
    end

    def in_set?(z)
      @z = z
      @max_iterations.times { |i|
        @z = @z**2 + @c
        if @z.abs > @bailout then
          @last_iteration = i
          return false
        end      
      }      
      return true
    end
  end

  class Mandelbrot < Fractal    
    attr_accessor :bailout, :last_iteration, :max_iterations        
    
    def initialize(c=Complex(-0.65, 0.0), bailout=2, max_iterations=50)
      super(c)
      @bailout, @max_iterations = bailout, max_iterations
    end

    def in_set?(c)
      @z = 0
      @max_iterations.times { |i|
        @z = @z**2 + c
        if @z.abs > @bailout then       
          @last_iteration = i
          return false
        end            
      }      
      return true
    end
  end

  module Algorithms  
    EscapeTime = lambda { |fractal| (765 * fractal.last_iteration / fractal.max_iterations).abs }    
    
    NormalizedIterationCount = lambda { |fractal|   
      fractal.z = fractal.z**2 + fractal.c; fractal.last_iteration += 1
      fractal.z = fractal.z**2 + fractal.c; fractal.last_iteration += 1
    
      modulus = Math.sqrt(fractal.z.real**2 + fractal.z.image**2).abs
      mu = fractal.last_iteration + Math.log(2 * Math.log(fractal.bailout)) - Math.log(Math.log(modulus)) / Math.log(2)
    
      (mu / fractal.max_iterations * 765).to_i
    }   
  end
  
  module Themes
    Fire = lambda { |index|
      r, g, b = 0, 0, 0      
      if index >= 510
        r = 255
        g = 255
        b = index % 255
      elsif index >= 255
        r = 255
        g = index % 255   
      else
        r = index % 255
      end      
      return r, g, b
    }    
    
    Water = lambda { |index|      
      r, g, b = 0, 0, 0  
      if index >= 510
        r = index % 255
        g = 255 - r
      elsif index >= 255
        g = index - 255
        b = 255 - g       
      else
        b = index
      end       
      return r, g, b
    }
    
    None = lambda { |index| return 255, 255, 255 }
  end
end

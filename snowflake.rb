require 'fractals'
require 'png'
include Fractals

x = []
(0..2).each do |i|
  (0..2).each do |j|
    x << [ i, j ]
  end
end
  
snowflakes = Julia.new(Complex(-0.3007, 0.6601), 5, 100)
snowflakes.width = 360
snowflakes.height = 360
snowflakes.m = 2
snowflakes.set_color = PNG::Color::White
snowflakes.algorithm = Algorithms::NormalizedIterationCount
snowflakes.theme = lambda { |index|
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
x.each do |p|
  snowflakes.pieces =  [ 3, 3 ]
  snowflakes.piece = p
  snowflakes.draw("public/snowflakes#{p[0]}.#{p[1]}.png")
end

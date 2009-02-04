
require 'rush'
require 'lib/fractmq'

def box
  @box ||= Rush::Box.new
end

def pwd
  @pwd ||= box[ Dir.pwd + '/' + FractMQ.dir ]
end



require 'rush'
require 'lib/snowflake'

def box
  @box ||= Rush::Box.new
end

def pwd
  @pwd ||= box[ Dir.pwd + '/']
end


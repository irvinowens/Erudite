require File.dirname(__FILE__) + '/Erudite/discovery.rb'
require File.dirname(__FILE__) + '/Erudite/distribute.rb'

# The erudite gem is a runtime that provides a data store which
# features automatic clustering, a sql interface on port 3306,
# a map / reduce interface ( using ruby )
# and a file base storage mechanism for maximum flexibility

module Erudite
  # Your code goes here...
  include Disco
  discovery = Cluster.new
  
end

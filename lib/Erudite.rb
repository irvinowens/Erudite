require File.dirname(__FILE__) + '/Erudite/discovery.rb'
require File.dirname(__FILE__) + '/Erudite/distribute.rb'

# The erudite gem is a runtime that provides a data store which
# features automatic clustering, a sql interface on port 3306,
# a map / reduce interface ( using ruby )
# and a file base storage mechanism for maximum flexibility
# the physical architecture is a set of index files that is created
# upon saving content and each entry is tied to the physical object
# for text objects, all tokens are identified and tied to the location
# of the document to make lookup quick
# to reduce the content, add a ruby function to further limit
# the match.

module Erudite
  # Your code goes here...
  include Disco
  discovery = Cluster.new
  
end

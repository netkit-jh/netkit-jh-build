#!/usr/bin/ruby
require 'json'


$sizes = []

def findsizes(hash)
  if hash 
    findsizes(hash["firstChild"]) if hash["firstChild"]
    findsizes(hash["secondChild"]) if hash["secondChild"]
  
    $sizes.append([hash["id"], hash["rectangle"]["width"], hash["rectangle"]["height"]]) if hash["client"]
  end
end


my_hash = JSON.parse(gets)

r = my_hash["root"]
findsizes(r)
if $sizes == []
  print ""
else
  print "0x%08x" % $sizes.max_by{|x,y,z| y*z}[0]
end

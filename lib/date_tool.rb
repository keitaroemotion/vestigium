require 'date'

def d_to_i(y,m,d) #date obj
  d = Date.new(y, m, d)
  epoch = Date.new(1970, 1, 1)
  (d - epoch).to_i
  return d.to_time.to_i
end


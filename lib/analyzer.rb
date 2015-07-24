require '/usr/local/etc/vestigium/math/average'
require '/usr/local/etc/vestigium/math/median'
require '/usr/local/etc/vestigium/math/standard_deviation'
require '/usr/local/etc/vestigium/math/filter'
require '/usr/local/etc/vestigium/math/mode'

def wait(flag=1)
  case flag
  when 0
    print ""
    if $stdin.gets.chomp == "q"
      abort
    end
  when 1
    puts
    sleep(0.5)
  else
  end
end

def analyze(oper, scheme_id, schema, tmp)
  formula = oper.split('|')[1]
  if formula == nil
    abort "formula not implemented.".red
  end
  formula = formula.strip

  tokens = formula.split(' ')
  function = tokens[0]
  args = tokens[1..tokens.size]

  case function
  when "mean" # means
    res = get_average function, args, tmp, scheme_id
    print "#{formula.green} : "
    print res.to_s.cyan
  when "sdev" # standard deviation
    print "#{formula.green} : "
    print get_standard_deviation(function, args, tmp, scheme_id).to_s.yellow
  when "median"
    print "#{formula.green} : "
    print get_median(function, args, tmp, scheme_id).to_s.yellow
  when "mode"
    print "#{formula.green} : "
    puts
    c = 0
    get_mode(function, args, tmp, scheme_id).each do |data|
      print "  ["
      if c == 0
        print data[0].to_s.magenta.swap
      else
        print data[0].to_s.magenta
      end
      print "] "
      print data[1].underline.yellow
      puts
      c += 1
    end
  when "filter"
    filter(function, args, tmp, scheme_id)
  else
    abort "oper does not exist!"
  end
  wait
end


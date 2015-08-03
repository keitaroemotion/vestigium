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

def analyze(oper, scheme_id, schema, tmp, settings=nil)
  puts
  formula = oper.split('|')[1]
  if formula == nil
    abort "formula not implemented.".red
  end
  formula = formula.strip

  print "[Formula] "
  puts formula.red
  # find selection word

  def get_extra_queries(formula)
    extra_queries = Hash.new
    if formula.include? "("
       formulas = formula.split('(')
       formula = formulas[0]
       formulas = formulas[1..formulas.size-1]
       formulas.each do |extra_func|
         extra_func = extra_func.gsub(")","").split(' ')
         extra_args = Array.new
         extra_func[1..extra_func.size-1].each do |elem|
           elem.split(",").each do |e|
             extra_args.push e
           end
         end
         extra_func = extra_func[0]
         extra_queries[extra_func] = extra_args
       end
    end
    extra_queries
  end

  extra_queries = get_extra_queries(formula)

  tokens = formula.split(' ')
  function = tokens[0]
  args = tokens[1..tokens.size]

  def print_analysis(function, args, tmp, scheme_id, formula, extra_queries, settings=nil)
    case function
    when "mean" # means
      res = get_average(function, args, tmp, scheme_id, extra_queries, settings)
      print "["
      print "Result".blink
      print "] "
      res.each do |line|
        if line[0] != ""
          print "#{line[0]} ".red
        end
        puts line[1].to_s.cyan
      end
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
  print_analysis(function, args, tmp, scheme_id, formula, extra_queries, settings)
end


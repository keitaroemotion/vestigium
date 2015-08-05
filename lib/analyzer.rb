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

def analyze(oper, scheme_id, schema, tmp, settings, reports)
  #puts
  formula = oper.split('|')[1]
  if formula == nil
    abort "formula not implemented.".red
  end
  formula = formula.strip

  #print "[Formula] "
  #puts formula.red
  # find selection word

  def get_extra_queries(formula)
    extra_queries = Hash.new
    if formula.include? "("
       formulae = formula.split('(')
       formula = formulae[0]
       formulae = formulae[1..formulae.size-1]
       formulae.each do |extra_func|
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

  def print_analysis(function, args, tmp, scheme_id, formula, extra_queries, settings, reports)
    case function
    when "mean" # means
      reports[formula] = ["mean", get_average(function, args, tmp, scheme_id, extra_queries, settings, true)]
    when "sdev" # standard deviation
    when "sum"
      reports[formula] = ["sum", get_selected_result(args, tmp, scheme_id, extra_queries, settings, "sum", true)]
    when "count"
      reports[formula] = ["count", get_selected_result(args, tmp, scheme_id, extra_queries, settings, "count", true)]
    when "median"
      reports[formula] = ["median", get_median(function, args, tmp, scheme_id, extra_queries, settings, true)]
    when "mode"
    when "filter"
      reports[formula] = ["filter", filter(function, args, tmp, scheme_id)]
    else
      #puts "oper does not exist!".swap.red
    end
    return reports
  end
  return print_analysis(function, args, tmp, scheme_id, formula, extra_queries, settings, reports)
end


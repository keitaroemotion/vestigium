require '/usr/local/etc/vestigium/math/average'

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
  when "aver"
    res = get_average function, args, tmp, scheme_id
    print "#{formula.green} : "
    puts res.to_s.cyan
  else
    abort "oper does not exist!"
  end
end


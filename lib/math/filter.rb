def evaluate(target, operand, compared_num)
  target = target.to_f
  case operand
  when ">"
    return target > compared_num
  when "<"
    return target < compared_num
  when "<="
    return target <= compared_num
  when ">="
    return target >= compared_num
  when "=="
    return target == compared_num
  else
    abort "error"
  end
end

def filter(function, args, tmp, scheme_id)
  operand = args[0]
  compared_num = args[1].to_f
  funct = args[2]
  keyword = args[3]

  keyindex = get_keyindex_in_table tmp, scheme_id, keyword
  data_array = get_data_array get_data(tmp, scheme_id, $db), keyindex
  filtered_data = Hash.new
  index = 0
  data_array.each do |data|
    res = evaluate data, operand, compared_num
    if res == true
       filtered_data[index] = data
    end
    index += 1
  end
  case funct
  when "count"
    print "#{function}".green
    print " [ "
    print "#{keyword} "
    print " #{operand} "
    print "#{compared_num}".cyan
    print " ]"
    print " #{funct}".green
    print " : "
    puts filtered_data.size.to_s.yellow
  when "raw"
  else
  end
end

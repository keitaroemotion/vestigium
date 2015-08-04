def get_standard_deviation(function, args, tmp, scheme_id, extra_queries, settings=Hash.new, console=true)
  key = args[0]
  keyindex = get_keyindex_in_table tmp, scheme_id, key
  results = get_average function, args, tmp, scheme_id, extra_queries, settings, true
  ret = Array.new

  results.keys.each do |key|
    result = results[key]
    mean = result[0]
    sum  = result[1]
    actual_data = result[2]

    subtr_total = 0
    actual_data.each do |elem|
      subtr_total += ((elem.to_f - mean)**2)
    end
    ret.push [key, Math.sqrt(subtr_total/actual_data.size).to_s[0..4].to_f]
  end
  return ret
end


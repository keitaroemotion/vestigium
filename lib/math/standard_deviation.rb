def get_standard_deviation(function, args, tmp, scheme_id)
  key = args[0]
  keyindex = get_keyindex_in_table tmp, scheme_id, key
  #get_sum(data, keyindex)
  means = get_average function, args, tmp, scheme_id
  data_array = get_data_array get_data(tmp, scheme_id, $db), keyindex
  subtr_total = 0
  data_array.each do |x|
    subtr_total += ((x - means)**2)
  end
  return Math.sqrt(subtr_total/data_array.size).to_s[0..4].to_f
end


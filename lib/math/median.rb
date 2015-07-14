def get_median(function, args, tmp, scheme_id)
  key = args[0]
  keyindex = get_keyindex_in_table tmp, scheme_id, key
  data_array = get_data_array get_data(tmp, scheme_id, $db), keyindex
  data_array = data_array.sort
  n = data_array.size
  if n % 2 == 1
    return data_array[(n-1)/2]
  else
    return (data_array[(n/2)-1] + data_array[n/2])*0.5
  end
end


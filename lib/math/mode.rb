def get_mode(function, args, tmp, scheme_id)
  rank_range = args[0]
  keyword = args[1]
  keyindex = get_keyindex_in_table tmp, scheme_id, keyword
  data_array = get_data_array_str get_data(tmp, scheme_id, $db), keyindex
  data_array = data_array.sort
  data_categorized = Hash.new
  data_array.each do |data|
    if data_categorized.keys.include? data
      data_categorized[data] = data_categorized[data]+1
    else
      data_categorized[data] = 1
    end
  end

  data_for_mode = Hash.new
  data_categorized.keys.each do |key|
     data_for_mode[data_categorized[key]] = key
  end
  data_for_mode = data_for_mode.sort.reverse

  result = Array.new
  if rank_range != nil
    rank_range = rank_range.to_i
  else
    rank_range = -1
  end

  i = 0
  data_for_mode.each do |set|
    if i == rank_range
      break
    end
    result.push set
    i += 1
  end

  return result
end

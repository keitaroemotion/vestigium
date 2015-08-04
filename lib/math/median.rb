def get_median(function, args, tmp, scheme_id, extra_queries, settings, console)
  key = args[0]
  keyindex = get_keyindex_in_table tmp, scheme_id, key
  return get_selected_result args, tmp, scheme_id, extra_queries, settings, "median", console
end


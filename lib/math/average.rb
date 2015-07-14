require '/usr/local/etc/vestigium/utility'

def get_average(function, args, tmp, scheme_id)
  target_colname =  args[0] # date
  count = get_keyindex_in_table tmp, scheme_id, target_colname
  bank = get_data(tmp, scheme_id, $db)
  return get_sum(bank, count) / bank.size
end

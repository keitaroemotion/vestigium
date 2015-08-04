require '/usr/local/etc/vestigium/utility'
require '/usr/local/etc/vestigium/controller'


def get_average(function, args, tmp, scheme_id, extra_queries, settings, console)
  result = get_selected_result args, tmp, scheme_id, extra_queries, settings, "mean", console
  if result.size == 0
    puts "RESULT SIZE ZERO".swap.red
    return -1
  end
  return result
end

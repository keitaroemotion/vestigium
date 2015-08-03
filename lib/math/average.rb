require '/usr/local/etc/vestigium/utility'
require '/usr/local/etc/vestigium/controller'



def get_average(function, args, tmp, scheme_id, extra_queries=nil, settings=nil)
  target_colname =  args[0] # date
  count = get_keyindex_in_table tmp, scheme_id, target_colname

  where = get_where(extra_queries)
  selection_range = ""
  if where.include? "group by"
    selection_range = where.gsub("group by","")
    selection_range += ",#{target_colname}, count(*)"
  else
    #selection_range = "*"
    selection_range = target_colname
  end
  query = "select #{selection_range} from #{scheme_id}.#{scheme_id} #{where};"

  result = get_q_ret(tmp, scheme_id, $db, query , settings)

  if result.size == 0
    puts "RESULT SIZE ZERO".swap.red
    return -1
  end

  if where.include? "$"
    data = Hash.new
    puts
    sp = where.split("where")
    (1..sp.size-1).each do |x|
      sum = 0.0
      records = result[x-1].split("\n")
      records.each do |j|
        sum += j.to_f
      end

      print "[#{sp[x].strip.gsub('$','')}]\n".yellow
      print "  [Data Count] %-.2f\n" % records.size
      print "  [Data Total] %-.2f\n" % sum
      print "  [Mean]"
      print "       %-.2f\n\n".green % (sum/records.size.to_f)
    end
    return 0
  end




  print "  [Data Count] "
  puts result.size


  data = Hash.new

  if where.include? "group by"
    result.each do |line|
      lsp = line.split(' ')
      key = ""
      (0..lsp.size-3).each do |tok|
        key += "#{lsp[tok]}|"
      end
      target_data = lsp[lsp.size-2].to_f
      each_count = lsp[lsp.size-1].to_f

      puts "#{target_data.to_s.yellow}  #{each_count.to_s.red}"


      if ((key == "NULL|") || (key == ":|"))
        next
      end

      if data.has_key? key
        data[key] = [target_data*each_count+data[key][0], each_count+data[key][1]]
      else
        data[key] = [target_data*each_count, each_count]
      end
    end

    data.keys.each do |k|
      if data[k][1] > 0
        data[k] = data[k][0]/data[k][1]
      else
        data.delete k
      end
    end
    return data
  elsif where == ""
    sum = get_sum(result, count)
    print "  [Data Total] "
    puts sum
    data[""] = sum / result.size
    return data
  else
    sum = 0
    result.each do |line|
      sum += line.to_f
    end
    print "  [Data Total] "
    puts sum
    data[""] = sum / result.size
    return data
  end
end

def get_data_array(data, count)
  arr = Array.new
  data.each do |line|
    arr.push line.split("|")[count].to_f
  end
  return arr
end

def get_data_array_str(data, count)
  arr = Array.new
  data.each do |line|
    arr.push line.split("|")[count]
  end
  return arr
end

def get_sum(data, count)
  sum = 0
  data.each do |line|
    sum += line.split("|")[count].to_f
  end
  return sum
end

def get_keyindex_in_table(tmp, scheme_id, target_colname, testkey="")
  count = 0
  if target_colname == nil
    print "#{testkey} : ".green
    print "Test Error! ".red.blink
    return 0
  else
    get_table_schema(tmp, scheme_id, $db).chomp.split("\n").each do |line|
      if ((line.split('|')[1].strip.chomp == target_colname.strip.chomp))
        break
      end
      count += 1
    end
    return count
  end
end


def color_print(text, color)
  if text != nil
    case color
    when "green"
      print text.green
    when "yellow"
      print text.yellow
    else
      print text
    end
  end
end

def showERR(args, size)
  if ARGV.size < size
    abort "arg size not sufficient"
  end
end


def file_to_map(config_path)
  hash = Hash.new
  File.open(config_path, "r").each do |line|
    if line.include? "="
      tokens = line.split('=')
      hash[tokens[0].strip.chomp] = tokens[1].strip.chomp
    end
  end
  return hash
end


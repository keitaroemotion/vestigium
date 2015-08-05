def format_num(num)
  num = "%.2f" % num
  nums = num.to_s.split('.')
  num = nums[0]
  fraction = nums[1]
  digit = ""
  count = 0
  chars = num.to_s.split('').reverse
  chars.each do |d|
    if count == 3
      digit = "#{d},#{digit}"
      count = 1
    else
      digit = "#{d}#{digit}"
      count += 1
    end
  end
  digit = "#{digit}.#{fraction}"
  return digit
end


def display(report)
  report.each do |elem|
    vals = Array.new
    max_val_size = 0
    elem.keys.each do |e|
       if elem[e][0] != nil
         val = format_num("%.2f" % elem[e][0])
         if val.size > max_val_size
           max_val_size = val.size
         end
       else
         val = "---"
       end
       vals.push [e.green, val]
    end
    vals.each do |val|
      print "#{val[0]} "
      (0..max_val_size - val[1].size).each do |r|
        print " "
      end
      print "#{val[1].yellow}"
      puts
    end
  end
end


def print_timer(t2, t1)
  diff = t1 - t2
  hour = diff/3600
  rem = diff%3600
  min = rem/60
  sec = rem%60
  hour = ""
  if hour.to_i > 0
    hour = "#{hour.to_i} hr "
  end
  return "#{hour}#{min.to_i} min #{sec.to_i} sec ".chomp
end

def get_schema_id
  puts "--- Schema ID List  ---"
  list_schema
  print "choose the schema id: "
  schema_id = $stdin.gets.chomp
  if File.exist?("#{$schema}/#{schema_id}.schema") == true
    return schema_id
  else
    Dir["#{$schema}/*"].each do |file|
      file_name = file.gsub("#{$schema}/","").gsub(".schema","")
      if file_name.start_with? schema_id
        print "You want to use "
        print "#{file_name} ".green
        print "? [Y/n] : "
        if  $stdin.gets.chomp.downcase == "y"
          return file_name
        else
        end
      end
    end
  end

  return schema_id
end

def get_commands(scheme_id, lines)
  commands = Array.new
  File.open("#{$schema}/#{scheme_id}.schema", "r").each do |line|
    line = line.chomp.strip
    if line.include? "|"
      lsp = line.split "|"
      lines[lsp[0].strip.chomp] = lsp[1].chomp.strip
    end
    if line.start_with? "=>"
      line.strip.gsub("=>","").split(',').each do |com|
        if com != nil
          commands.push com.strip
        end
      end
    end
  end
  return [commands, lines]
end

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
    get_table_schema(scheme_id, target_colname)
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


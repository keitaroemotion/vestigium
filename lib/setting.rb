$conf_keys = ["query", "result"]


def read_console_conf(args=nil)
  additional_cond = Hash.new
  if args != nil
    args.each do |x|
      if x.include? "="
        x = x.split('=')
        additional_cond[x[0]] = x[1]
      elsif x.start_with? "no-"
        additional_cond[x.gsub("no-","")] = "no"
      else
        additional_cond[x] = "yes"
      end
    end
  end

  curr_set = Hash.new
  if File.exist? $console_conf
    File.open($console_conf, "r").each do |line|
      if line.include? "="
        lsp = line.strip.split('=')
        if additional_cond.has_key? lsp[0]
          curr_set[lsp[0]] = additional_cond[lsp[0]]
        else
          curr_set[lsp[0]] = lsp[1]
        end
      end
    end
  end
  curr_set
end

def show_console_conf()
  File.open($console_conf, "r").each do |line|
    puts line.chomp.yellow
  end
end

def write_console_conf()
  print "Enter the Key: "
  key = $stdin.gets.chomp
  if $conf_keys.include?(key) == false
    puts "the key '#{key}' does not exist. ".swap
    write_console_conf()
    return
  end
  print "Enter the Value:"
  value = $stdin.gets.chomp

  curr_set = read_console_conf

  if curr_set.has_key? key
    f = File.open($console_conf, "w")
    curr_set.keys.each do |k|
      if k == key
        f.puts "#{k}=#{value}"
      else
        f.puts "#{k}=#{curr_set[k]}"
      end
    end
    f.close
  else
    f = File.open($console_conf, "a")
    f.puts "#{key}=#{value}"
    f.close
  end
  puts "Set: #{key} = #{value}".green
end


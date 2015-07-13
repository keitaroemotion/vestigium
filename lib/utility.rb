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


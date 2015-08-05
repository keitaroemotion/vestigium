require 'rubygems'
require 'colorize'
require '/usr/local/etc/vestigium/date_tool'
require '/usr/local/etc/vestigium/controller_helper'
require 'parallel'

$sqldir = "/usr/local/etc/vestigium/query"
$repodir = "/usr/local/etc/vestigium/report"
$schemadir = "/usr/local/etc/vestigium/schema"
$tmp_path_cql = "#{$sqldir}/tmp.cql"


def get_selected_result(args, tmp, scheme_id, extra_queries, settings, opt, console)

  target_colname =  args[0] # date
  count = get_keyindex_in_table tmp, scheme_id, target_colname
  where = get_where(extra_queries)
  selection_range = ""
  if where.include? "group by"
    selection_range = where.gsub("group by","")
    selection_range += ",#{target_colname}, count(*)"
  else
    selection_range = target_colname
  end
  query = "select #{selection_range} from #{scheme_id}.#{scheme_id} #{where};"

  data = Hash.new
  #puts
  sp = where.split("where")

  key = ""
  report = Hash.new

  if !where.include? "where"
    sp = [nil, "Result"]
    key = "Result"
  end

  result = get_q_ret(tmp, scheme_id, $db, query , settings)

  (1..sp.size-1).each do |x|

    key = sp[x].gsub("$","")

    sum = 0.0
    records = result[x-1].split("\n")
    records.each do |j|
      sum += j.to_f
    end

    case opt
    when "median"
      median = 0
      arr = Array.new
      if records.size == 0
        report[key] = ""
        return report
      end
      records.each do |e|
        arr.push e.to_i
      end
      arr = arr.sort
      n = arr.size
      if arr.size % 2 == 1
        median = arr[(n-1)/2]
      else
        median = (arr[(n/2)-1] + arr[n/2])*0.5
      end
      report[key] = [median]
    when "sum"
      report[key] = [sum]
    when "count"
      report[key] = [records.size]
    when "mean"
      report[key] = [sum/records.size.to_f, sum, records]
    else
    end
   end
  return report
end

def get_where(extra_queries)
  where = ""
  if extra_queries != nil
    where = ""
    extra_queries.each do |extra_query|
      func_key = extra_query[0]
      if  func_key == "group_by"
        additional = ""
        dates = nil
        if extra_queries.has_key? "interval"
          args = extra_queries["interval"]
          tmp_query = "delete from non_filt.non_filt where #{args[0]}='0000-00-00 00:00:00';"
          tmp_query += "select MAX(#{args[0]}) AS #{args[0]} from non_filt.non_filt;"
          tmp_query += "select MIN(#{args[0]}) AS #{args[0]} from non_filt.non_filt;"

          dates = Array.new

          %x(mysql --user=vest --pass=vest -e "#{tmp_query}").split("\n").each do |date|

            if date != args[0]
              dates.push DateTime.strptime(date.strip, '%Y-%m-%d %I:%M:%S')
            end
          end
          dates =  dates.sort

          dfrom = dates[0]

          def add_date_range(dfrom, maxdate, colname, queries)
            dto = dfrom + Rational(5, 24*60)
            queries.push " #{colname} BETWEEN '#{dfrom}' AND '#{dto}' "
              puts "dto: #{dto} maxdate:#{maxdate}".swap
            if dto < maxdate
              add_date_range dto, maxdate, colname, queries
            else
              return queries
            end
          end

          dates = add_date_range dfrom, dates[dates.size-1], args[0], Array.new

        end

        if extra_queries.has_key? "filter"
          args = extra_queries["filter"]
          # if args increased, this doesnt help
          value = ""
          if args[1].start_with? "!"
            value = "<>'#{args[1]}'".gsub("!","")
          else
            value = "='#{args[1]}'"
          end
          additional = "and #{args[0]}#{value}"
        end
        tokens = extra_query[1]
        tmp = "where #{tokens[0]}="
        puts dates.size.to_s.swap
        tokens[1..tokens.size-1].each do |e|
          if dates != nil
            dates.each do |date|
              where += "#{tmp}'#{e}' #{additional} and #{date} $"
            end
          else
            where += "#{tmp}'#{e}' #{additional}$"
          end
        end
      end
    end
  end
  puts where.yellow
  return where
end


def make_tmp_directory()
  if File.directory?($sqldir) == false
    system "mkdir -p #{$sqldir}"
  end
end

def list_schema()
  Dir["#{$schemadir}/*"].each do |schema_id|
    puts schema_id.gsub("#{$schemadir}/","").gsub(".schema","").green
  end
end

def reflect_schema(schema_id, schema, key_index_est=true)
  schemainfo = Hash.new
  schema_path = "#{$schemadir}/#{schema_id}.schema"
  if File.exist?(schema_path) == false
    print "the following path does not exist: ".red
    abort "#{schema_path}"
  end

  schema_flag = false
  File.open(schema_path, "r").each do |line|
   if line.start_with? "@schema"
     schema_flag = true
     next
   end
   if schema_flag == true
     if line.include?("|")
       line = line.gsub("|","").strip.split(' ')
       value =  line[0]
       key = line[1].to_i
       if value.start_with? '('
         key = ""
         line[0..line.size].each do |elem|
           key += "#{elem.gsub('(','').gsub(')','')} "
         end
         value = key
         key = -1
       end
       if schemainfo.keys.include? key
         print "key duplicated: #{key}".red.swap
         print " (#{schemainfo[key]}, #{value})\n".red.swap
         abort ""
       end
       schemainfo[key] = value
     else
       break
     end
   end
  end
  return schemainfo
end

def sample_log(file, target_index=10)
 i = 0
 File.open(file, "r").each do |line|
    if i == target_index
      j = 0
      line.split(' ').each do |token|
        print "["
        print j.to_s.red
        print "] "
        puts "#{token}".yellow
        j += 1
      end
      break
    end
    i += 1
  end
end

def create_user(schema_id)
  puts "Creating User...".yellow
  user_name = "vest"
  pass_word = "vest"
  ip_addr = "localhost"

  query =  "CREATE DATABASE #{schema_id};"+
           "USE #{schema_id};"+
           "CREATE USER '#{user_name}'@'#{ip_addr}' IDENTIFIED BY '#{pass_word}';"+
           "GRANT ALL PRIVILEGES ON *.* TO '#{user_name}'@'#{ip_addr}' WITH GRANT OPTION;"
  create_user_file = "#{$db}/create_user_#{schema_id}.cql"
  f = File.open(create_user_file, "w")
  f.puts query
  f.close
  system "mysql --user=root < #{create_user_file}"
  puts "User registration finished!".swap
  system "rm #{create_user_file}"
end


def check_query_error(col)
  reserved = ["from"]
  if reserved.include? col.strip
      puts
      abort "the column name '#{col}' inappropriate because it is reserved.".red.swap
  end
end

def log_to_database(file, scheme_id, schema, limit=1000)
  $file_count = 0
  create_user scheme_id

  table_creation_query = "use #{scheme_id}; "
  table_creation_query += "create table #{scheme_id} ( "
  schema =  reflect_schema scheme_id, schema


  def convert_func_to_value(label, i)
    token = label[i].split(' ')
    case token[0]
    when "concat"
      return token[1]
    else
      return label[i]
    end
  end

  schema.keys.each do |column|
    check_query_error schema[column]
    colval = convert_func_to_value schema, column
    case column
    when -1
      table_creation_query += "#{colval} DATETIME,"
    else
      table_creation_query += "#{colval} CHAR(10),"
    end
  end
  puts
  table_creation_query = table_creation_query[0 .. table_creation_query.size-2]
  table_creation_query += " );"

  puts table_creation_query.yellow.swap
  make_tmp_directory

  tmp_lines = ""

  puts "     Table creation query     ".swap
  puts table_creation_query.yellow
  tmp_lines += table_creation_query

  select_path = "#{$sqldir}/select.cql"
  fsel = File.open(select_path, "w")
  fsel.puts table_creation_query
  fsel.close

  res  = %x(mysql --user=vest --pass=vest < #{select_path})

  def put_into_db(scheme_id, cqlpath)
    res = %x(mysql --user=vest --pass=vest < #{cqlpath})
  end


  puts "Reading from log file...".swap
  lines = File.read(file).each_line.to_a

  $UNIT = 1500

  def facere(m, lines, schema, scheme_id, init_time)
    result = multi_process(lines, m, schema, scheme_id, $UNIT)
    t2 = Time.now
    time = print_timer(init_time, t2)
    percent = (result.to_f/lines.size.to_f*100).to_i
    print "#{percent}%  [#{result+1}/#{lines.size}]\r".green.swap
    if result > lines.size
    else
      facere result+1, lines, schema, scheme_id, init_time
    end
  end

  print "0%  [0/#{lines.size}]\r".green.swap

  init_time = Time.now
  facere 0, lines, schema, scheme_id, init_time
  numero = 0
  system "rm #{$sqldir}/select.cql"

  require 'FileUtils'
  FileUtils.mkdir_p "#{$repodir}"
  $total_file = "#{$repodir}/total.txt"
  t = File.open($total_file, "w")
  dir_content = Dir["#{$sqldir}/*"]
  dir_content.each do |sqlfile|
    print "Deleting Tmp Queries ... [#{numero}/#{dir_content.size}]\r".swap
    r = File.read(sqlfile)
    t.puts r
    FileUtils.rm sqlfile
    numero += 1
  end
  print "Inserting log into database...      \n"
  syntax =  "LOAD DATA INFILE '#{$total_file}' INTO TABLE #{scheme_id}.#{scheme_id};"
  %x( mysql -v --user=vest --pass=vest -e "#{syntax}")
  puts "Conversion finished! (#{print_timer(init_time, Time.now)})".green.blink
end

def get_table_schema(scheme_id, target_colname)
  #f = File.open(tmp, "w")
  #f.puts "PRAGMA table_info(#{scheme_id});"
  #f.close
  #return %x(sqlite3 "#{db}/#{scheme_id}.db" < #{tmp})
  query = "SHOW COLUMNS FROM #{scheme_id}.#{scheme_id};"
  res = %x(mysql --user=vest --pass=vest -e "#{query}")
  c = -1
  res.split("\n").each do |row|
    field = row.split(' ')[0]
    if field == target_colname
      return c
    end
    c += 1
  end
  abort "ERROR".red
end

def get_q_ret(tmp, scheme_id, db, query, settings=nil)
  # for where
  res = Array.new
  if query.include? "$"
    qsp = query.split('where')
    qsp[1..qsp.size-1].each do |q|
      query = "#{qsp[0]} where #{q};".gsub('$','').gsub(";;",";")
      print "[Query] "
      puts query.chomp.magenta
      res.push %x(mysql --user=vest --pass=vest -e "#{query}")
    end
    return res
  end

  if ((settings != nil) && (settings["query"] == "yes"))
    print "[Query] "
    puts query.magenta
  end
  res.push %x(mysql --user=vest --pass=vest -e "#{query}")
  if ((settings != nil) && (settings["result"] == "yes"))
    puts res.to_s[1..100].green
  end
  return res
end





require 'rubygems'
require 'colorize'
require '/usr/local/etc/vestigium/date_tool'

$sqldir = "/usr/local/etc/vestigium/query"
$schemadir = "/usr/local/etc/vestigium/schema"
$tmp_path_cql = "#{$sqldir}/tmp.cql"


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

  File.open(schema_path, "r").each do |line|
    if line.start_with? "schema"
      content = line.gsub("schema","")
      content.split('|').each do |c|
        ctokens = c.split(' ')
        if ctokens.size > 1
          if key_index_est
            schemainfo[ctokens[1].strip.to_i] = ctokens[0].strip
          else
            schemainfo[ctokens[0].strip.to_i] = ctokens[1].strip
          end
        end
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

def log_to_database(file, scheme_id, schema, limit=1000)
  table_creation_query = "create table #{scheme_id} ( "
  schema =  reflect_schema scheme_id, schema
  schema.keys.each do |column|
    print "#{schema[column]}|".cyan
    table_creation_query += "#{schema[column]},"
  end
  puts
  table_creation_query = table_creation_query[0 .. table_creation_query.size-2]
  table_creation_query += " );"

  cql_buffer = open_q_file

  cql_buffer.puts table_creation_query

  i = 0  # safety

  File.open(file, "r").each do |line|
    if i == limit
      break
    end
    token = line.split(' ')

    if token[1] != nil
      values = ""
      schema.keys.each do |ind|
        if schema[ind] == "date"
          dtk = token[ind].split('-')
          token[ind] = d_to_i(dtk[0].to_i, dtk[1].to_i, dtk[2].to_i).to_s
        end
        color_print token[ind] , "green"
        values += "'#{token[ind]}',"
        print " "
      end
      cql_buffer.puts "insert into #{scheme_id} values (#{values[0..values.size-2]});"
      puts
    end
    i += 1
  end

  cql_buffer.close

  res = %x(sqlite3 "#{$db}/#{scheme_id}.db" < #{$tmp_path_cql})
  puts res.yellow
  puts "FINISH".red
  system "rm #{$tmp_path_cql}"
end

def get_table_schema(tmp, scheme_id, db)
  f = File.open(tmp, "w")
  f.puts "PRAGMA table_info(#{scheme_id});"
  f.close
  return %x(sqlite3 "#{db}/#{scheme_id}.db" < #{tmp})
end

def get_data(tmp, scheme_id, db, where="")
  f = File.open(tmp, "w")
  f.puts "select * from #{scheme_id} #{where};"
  f.close
  res =  %x(sqlite3 "#{db}/#{scheme_id}.db" < #{tmp})
  return res.chomp.split("\n")
end

def open_q_file()
  if File.directory?($sqldir) == false
    system "mkdir -p #{$sqldir}"
  end
  return File.open($tmp_path_cql, "w")
end

def exe_query(queries, scheme_id)
  f = open_q_file
  do_query f, queries
  f.close
  res = %x(sqlite3 "#{scheme_id}.db" < #{$tmp_path_cql} )
  puts res
end


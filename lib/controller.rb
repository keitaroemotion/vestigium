require 'rubygems'
require 'colorize'
require '/usr/local/etc/vestigium/date_tool'

$sqldir = "/usr/local/etc/vestigium/query"
$tmp_path_cql = "#{$sqldir}/tmp.cql"

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

=begin
# create an items table
DB.create_table :items do
  primary_key :id
  String :name
  Float :price
end

# create a dataset from the items table
items = DB[:items]

# populate the table
items.insert(:name => 'abc', :price => rand * 100)
items.insert(:name => 'def', :price => rand * 100)
items.insert(:name => 'ghi', :price => rand * 100)

# print out the number of records
puts "Item count: #{items.count}"

# print out the average price
puts "The average price is: #{items.avg(:price)}"
=end

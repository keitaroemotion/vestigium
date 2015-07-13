require 'rubygems'
require 'sequel'
require 'colorize'
require '/usr/local/etc/vestigium/date_tool'

DB = Sequel.sqlite

puts d_to_i(2012,4,4).to_s.red

$schema_config = ""

# read schema


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

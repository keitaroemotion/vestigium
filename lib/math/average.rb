 def get_average(function, args, tmp, scheme_id)
   aver = 0
   target_index =  args[0] # date

   count = 0

   get_table_schema(tmp, scheme_id, $db).chomp.split("\n").each do |line|
     if line.split('|')[1].strip.chomp == target_index.strip.chomp
       break
     end
     count += 1
   end

   bank = get_data(tmp, scheme_id, $db).chomp.split("\n")
   bank.each do |line|
     aver += line.split("|")[count].to_f
   end
   aver /= bank.size
   return aver
end


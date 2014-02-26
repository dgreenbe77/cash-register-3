require 'pry'
require 'csv'

def get_item_information
  hash_array = []
  CSV.foreach('products.csv', headers: true) do |row|
    hash_array << row.to_hash
  end
  return hash_array
end

def display_options_menu
  get_item_information.each_with_index do |hash,index|
    puts "#{index+1}) Add item - $#{'%.2f' % hash["retail_price"]} - #{hash["name"]}"
end
puts "4) Complete Sale"
puts "5) Reporting\n\n"
puts "Make a selection:\n\n"
end

def prompt
  display_options_menu
  @order_input = gets.chomp.to_i
  @order_index = @order_input - 1
  return
end

def how_many_with_subtotal(order_index, order_input)
  customer_order_info = Hash.new(0)
  total_how_many = [0,0,0]
  until @order_input > 3
    puts "\nHow many?\n\n"
    input_how_many = gets.chomp.to_i
    total_how_many[@order_index] += input_how_many
    key = get_item_information[@order_index]["name"]
    subtotal = get_item_information[@order_index]["retail_price"].to_f * total_how_many[@order_index]
    profit = subtotal - (get_item_information[@order_index]["wholesale_price"].to_f * total_how_many[@order_index])
    customer_order_info.store(key, [total_how_many[@order_index], subtotal, get_item_information[@order_index]["SKU"], profit])
    values = customer_order_info.values.flatten
    grab_totals = customer_order_info.values.map {|array| array[0..-1][1]}
    subtotal = grab_totals.inject{|sum, total| sum + total}
    puts "\nSubtotal: $#{'%.2f' % subtotal}\n\n"
    puts prompt
  end
  @customer_order_final = customer_order_info
  @values = customer_order_info.values.flatten
  @grab_totals = customer_order_info.values.map {|array| array[0..-1][1]}
  @subtotal = @grab_totals.inject{|sum, total| sum + total}
  @grab_profits = customer_order_info.values.map {|array| array[0..-1][3]}
  @total_profits = @grab_profits.inject{|sum, total| sum + total}
  return
end

#get_item_information
#=> [{"SKU"=>"120945",
#  "name"=>"Light",
#  "wholesale_price"=>"2.50",
#  "retail_price"=>"5"},
 #{"SKU"=>"679340",
 # "name"=>"Medium",
  #"wholesale_price"=>"3.25",
 # "retail_price"=>"7.50"},
 #{"SKU"=>"328745",
 # "name"=>"Bold",
 # "wholesale_price"=>"4.75",
 # "retail_price"=>"9.75"}]

def complete_sale
  puts "\n\n===Sale Complete==="
  customer_order_final = @customer_order_final
  customer_order_final.each do |key, value1|
    puts "#{value1[0]} - #{key} $#{'%.2f' % value1[1]}\n\n"
  end
  puts "Total: $#{'%.2f' % @subtotal}\n\n"
  puts "What is the amount tendered?"
  print "$"
  @amount_tendered = gets.chomp.to_f
  return
end

def thank_you
  puts "\n\n===Thank You!==="
  puts "The total change due is $#{'%.2f' % (@amount_tendered - @subtotal)}\n\n"
  puts "#{Time.now.strftime('%m/%d/%y %I:%M %p')}"
  @time = Time.now.strftime('%m/%d/%y %I:%M %p')
  puts "================\n\n"
  @order_input = 5
end

def record
  CSV.open('record.csv', 'a') do |csv|
    @customer_order_final.each do |key, values|
      csv << [ @time, values[2], key, values[0], ('%.2f' % values[1]), ('%.2f' % values[3])]
    end
  end
end

def get_item_report
  array = []
  CSV.foreach('record.csv', headers: false) do |row|
    array << row
  end
  return array
end

def reporting
  puts "What date would you like reports for? (MM/DD/YYYY)\n\n"
  report_date = gets.chomp
  get_item_report.each do |values|
    if values[0].match(report_date)
      puts "\nOn #{values[0]} we sold:\n\n"
      puts "SKU: #{values[1]}, Name: #{values[2]}, Quantity: #{values[3]}, Revenue: $#{values[4]}, Profit: $#{values[5]}\n"
    else
      puts "Invalid Date:"
      report_date = gets.chomp
    end
  end
  puts "\n\nTotal Revenue: $#{'%.2f' % @subtotal}"
  puts "Total Profit: $#{'%.2f' % @total_profits}\n\n"
end

def options_for_cashier
  puts "\nWelcome to Daniel's Awesome Magic Coffee Emporium!\n\nThe Coffee is Hella Good!\n\n"
  prompt
  while @order_input > 3
    puts "\nNo Items Added\n\n"
    prompt
  end
  if @order_input < 4
    puts how_many_with_subtotal(@order_index, @order_input)
    puts "Subtotal: #{'%.2f' % @subtotal}"
  end
  if @order_input == 4
    complete_sale
    thank_you
  end
  if @order_input == 5
    record
    reporting
  end
end


options_for_cashier

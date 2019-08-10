if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'json'

current_dir = File.dirname(__FILE__ )
file_name = current_dir + "/cities.json"

unless File.exist?(file_name)
  abort "File not found!"
end

file = File.read(file_name, encoding:"utf-8")
cities = JSON.parse(file)
my_cities = Hash.new

idx = 0
cities.each do |key, value|
  puts "#{idx} #{cities[key]["rus"]}"
  my_cities[idx] = cities[key]["url"]
  idx += 1
end

print "\nгород::>>>"
i = gets.chomp.to_i
puts my_cities[i]


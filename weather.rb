if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'net/http'
require 'uri'
require 'rexml/document'

THE_CLOUDS = {0=>'Ясно', 1=>'Малооблачно', 2=>'Облачно', 3=>'Пасмурно'}

uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/69.xml")

response = Net::HTTP.get_response(uri)

doc = REXML::Document.new(response.body)

city_name_coding = doc.root.elements['REPORT/TOWN'].attributes['sname']

city_name = URI.unescape(city_name_coding)

current_forecast = doc.root.elements["REPORT/TOWN"].elements.to_a[0]

min_temp = current_forecast.elements['TEMPERATURE'].attributes['min']
max_temp = current_forecast.elements['TEMPERATURE'].attributes['max']

max_wind = current_forecast.elements['WIND'].attributes['max']

clouds_index = current_forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
clouds = THE_CLOUDS[clouds_index]

puts city_name
puts "температура от #{min_temp} до #{max_temp}"
puts "Ветер: #{max_wind} m/s"
puts clouds
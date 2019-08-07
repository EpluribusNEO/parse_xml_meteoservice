
#....................................................................#
#                                                                    #
# Прогноз погоды от сайта Метеосервис. Предоставлено Meteoservice.ru #
#                                                                    #
# ...................................................................#
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
THE_PEECIPITATIAN = {3=>'смешанные', 4=>'дождь', 5=>'ливень',
                     6=>'снег', 7=>'снег', 8=>'гроза', 9=>'нет данных', 10=>'без осадков'}

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
precipitation_index = current_forecast.elements['PHENOMENA'].attributes['precipitation'].to_i
precipitation = THE_PEECIPITATIAN[precipitation_index]


pressure = current_forecast.elements['PRESSURE'].attributes['max'].to_s

relwet = current_forecast.elements['RELWET'].attributes['max'].to_s

forecast = doc.root.elements["REPORT/TOWN/FORECAST"].attributes
month = current_forecast.attributes['month']
day   = current_forecast.attributes['day']
##precipitation - тип осадков:
# 3 - смешанные, 4 - дождь, 5 - ливень, 6,7 – снег, 8 - гроза, 9 - нет данных, 10 - без осадков

puts "Прогноз погоды от сайта Метеосервис\nпредоставлено Meteoservice.ru\n\n\n"
puts "#{city_name} [день:#{day} месяц:#{month}"
puts "Температура от #{min_temp} до #{max_temp}"
puts "Ветер: #{max_wind} m/s"
puts clouds
puts "Осадки: #{precipitation}"
puts "Давление (max): #{pressure}mm"
puts "Влажность: #{relwet}%"
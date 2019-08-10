
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
require 'json'

THE_CLOUDS = {0=>'Ясно', 1=>'Малооблачно', 2=>'Облачно', 3=>'Пасмурно'}
THE_PEECIPITATIAN = {3=>'смешанные', 4=>'дождь', 5=>'ливень',
                     6=>'снег', 7=>'снег', 8=>'гроза', 9=>'нет данных', 10=>'без осадков'}

# -------------------------------------------------------------------
current_dir = File.dirname(__FILE__ )
begin
  file_name = current_dir + "/cities.json"
  file = File.read(file_name, encoding:"utf-8")
  cities = JSON.parse(file)
rescue Errno::ENOENT => error
  abort "Не удалось открыть файл:\n[#{error.message}]"
rescue => error
  abort "Непредвиденная ошибка:\n[#{error.message}]"
end


my_cities = Hash.new

idx = 0
cities.each do |key, value|
  puts "#{idx} #{cities[key]["rus"]}"
  my_cities[idx] = cities[key]["url"]
  idx += 1
end

print "\nгород::>>>"
i = gets.chomp.to_i
begin
uri_city = URI.parse(my_cities[i])
rescue URI::InvalidURIError => error
  abort "Ошибка: неправильно указан индекс!\n[#{error.message}]"
rescue => error
  abort "Непредвиденная ошибка!\n[#{error.message}]"
end


# -------------------------------------------------------------------
begin
response = Net::HTTP.get_response(uri_city)
rescue SocketError => error
  abort "Нет соединения с Интернет!\n[#{error.message}"
rescue =>error
  abort "Необработанная ошибка! Возмлжно проблема с сетевым подключением!\n#{error.message}"
end

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
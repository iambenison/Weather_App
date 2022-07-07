require 'faraday'
require 'json'
require 'uri'

#Get Postal-Code from User
def get_postal_code(prompt)
  puts prompt
  postal_code = gets.chomp().to_s
end

#Validate the Postal-Code
def validate_postal_code(postal_code, no_more_tries, count, limit, invalid,prompt, tries)
  while postal_code.length != 6 and !no_more_tries
    if count < limit
      puts invalid
      puts prompt
      postal_code = gets.chomp().to_s
      count += 1
    else
      no_more_tries = true
    end
  end

  if no_more_tries
    puts tries
    return
  end
end

#Get the Location and Current Conditions
def api_call(params, key_url)

  res = Faraday.get(key_url) do |req|
    req.params = params

  end
  resp = JSON.parse(res.body)
end

#output the Weather Data
def output_weather(resp)
  condition = resp[0]["WeatherText"]
  temperature = resp[0]["Temperature"]["Metric"]["Value"].to_s
  feels_like = resp[0]["RealFeelTemperature"]["Metric"]["Value"].to_s

  puts "*************************************"
  puts "* Current Condition is " + condition
  puts "* Temperature is " + temperature + "C"
  puts "* Feels Like temperature is " + feels_like + "C"
  puts "*************************************"

end

#Call all methods and get the Weather Output
def get_weather
  prompt = "> Enter your Postal Code (A1A1A1)"
  invalid = "***** INVALID POSTAL CODE ****** \n "
  tries = "Number of tries exceeded"
  count = 0
  limit = 2
  no_more_tries = false
  key_url = "http://dataservice.accuweather.com/locations/v1/postalcodes/CA/search"
  api_key = ENV['MY_API_KEY']
  conditions_url = "http://dataservice.accuweather.com/currentconditions/v1/"
  detail = true

  postal_code = get_postal_code(prompt)

  validate_postal_code(postal_code, no_more_tries, count, limit, invalid,prompt, tries)

  begin
    params = {apikey: api_key, q: postal_code }
    resp = api_call(params, key_url)

    location = resp[0]["Key"]

    key_url = conditions_url + location

    params = {apikey: api_key, details: detail}
    resp = api_call(params, key_url)

    output_weather(resp)
  rescue
    puts invalid
  end
end

get_weather

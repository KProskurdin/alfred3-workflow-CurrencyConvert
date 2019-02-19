require 'net/http'
require 'uri'
require 'json'
require_relative 'functions'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']
apikey = data['apiKey']

result = getURI("https://free.currencyconverterapi.com/api/v6/currencies?apiKey=#{apikey}", "currencies")

result['results'].each do |key, value|
    temp = Hash[
        "title" => "#{key}",
        "icon" => Hash[
            "path" => "flags/#{key}.png"
        ],
        "arg" => "#{key}"
    ]
    output["items"].push(temp)
end

print output.to_json
require 'net/http'
require 'uri'
require 'json'
require_relative 'functions'

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

result = getURI("https://free.currencyconverterapi.com/api/v5/currencies", "currencies")

result['results'].each do |key, value|
    if units.include?(key)
        temp = Hash[
            "title" => "#{value['currencyName']}",
            "subtitle" => "#{key} #{value['currencySymbol']}",
            "icon" => Hash[
                "path" => "flags/#{key}.png"
            ],
            "arg" => "#{key}"
        ]
        output["items"].push(temp)
    end
end

print output.to_json
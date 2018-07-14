require 'net/http'
require 'uri'
require 'json'
require_relative 'functions'

hasARGV = false

if !ARGV[0].empty?
    hasARGV = true
end

output = Hash["items" => []]
data = JSON.parse(File.read('data.json'))
base = data['base']
units = data['units']

if hasARGV
    str = ARGV[0].lstrip.gsub('$', 'usd').gsub('￥', 'cny').gsub('¥', 'jpy').gsub('£', 'gbp').gsub('€', 'eur')
    to = str.match(/\sto\s/)
    cy = nil
    num = nil
    target = nil
    if to.nil?
        num = str.match(/^\d+(.\d+)?/)
        if !num.nil?
            num = num[0]
        end
        cy = str.match(/\s*[a-zA-Z]{3}/)
        if !cy.nil?
            cy = cy[0].lstrip.upcase
        end
    else
        matcher = str.match(/^(\d+(.\d+)?)\s*([a-zA-Z]{3})\sto\s([a-zA-Z]{3})/)
        if !matcher.nil?
            num = matcher[1]
            cy = matcher[3].lstrip.upcase
            target = matcher[4].lstrip.upcase
        end
    end
    if str.empty? || num.nil? || cy.nil?
        temp = Hash[
            "title" => 'No result',
            "icon" => Hash[
                "path" => 'icon.png'
            ]
        ]
        output["items"].push(temp)
    else
        if target.nil?
            if units.include?(cy)
                units.delete(cy)
            end
            units.each do |x|
                uri = URI("https://free.currencyconverterapi.com/api/v5/convert?q=#{cy}_#{x}")
                result = getURI(uri, "#{cy}_#{x}", 3600)

                result["results"].each do |key, value|
                    temp = Hash[
                        "title" => "#{(num.to_f*value['val']).round(2)} #{value['to']}",
                        "subtitle" => "#{cy} : #{value['to']} = 1 : #{value['val'].round(4)}",
                        "icon" => Hash[
                            "path" => "flags/#{value['to']}.png"
                        ],
                        "arg" => "#{value['val'].round(4)}"
                    ]
                    output["items"].push(temp)
                end
            end
        else
            uri = URI("https://free.currencyconverterapi.com/api/v5/convert?q=#{cy}_#{target}")
            result = getURI(uri, "#{cy}_#{target}", 3600)

            result['results'].each do |key, value|
                temp = Hash[
                    "title" => "#{(num.to_f*value['val']).round(2)} #{value['to']}",
                    "subtitle" => "#{cy} : #{value['to']} = 1 : #{value['val'].round(4)}",
                    "icon" => Hash[
                        "path" => "flags/#{value['to']}.png"
                    ],
                    "arg" => "#{(num.to_f*value['val']).round(2)}"
                ]
                output["items"].push(temp)
            end
        end
    end
else
    if units.include?(base)
        units.delete(base)
    end

    units.each do |x|
        uri = URI("https://free.currencyconverterapi.com/api/v5/convert?q=#{base}_#{x}")
        result = getURI(uri, "#{base}_#{x}", 3600)

        result["results"].each do |key, value|
            temp = Hash[
                "title" => "#{base} : #{value['to']} = 1 : #{value['val'].round(4)} ",
                "icon" => Hash[
                    "path" => "flags/#{value['to']}.png"
                ],
                "arg" => "#{value['val'].round(4)}"
            ]
            output["items"].push(temp)
        end
    end
end

print output.to_json
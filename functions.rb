require 'net/http'
require 'uri'
require 'json'
require 'date'

def getURI(url = "", cacheName = "", cacheIntervalInSeconds = 86400) #default cache interval is 1 day

    if(url == "" || cacheName == "")
        return ""
    end

    fileName = "cache/#{cacheName}.json";

    File.open(fileName, "a") {|f| f.write("") }

    json = File.read(fileName)

    result = json && json.length >= 2 ? JSON.parse(json) : nil

    if !result || !result['results'] || ((DateTime.now - DateTime.iso8601(result['date'])) * 24 * 60 * 60).to_i > cacheIntervalInSeconds
        uri = URI(url)
        result = JSON.parse(Net::HTTP.get(uri))
        result['date'] = DateTime.now.iso8601(9)
        File.write(fileName, result.to_json)
    end

    return result
end
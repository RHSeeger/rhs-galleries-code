require 'net/http'
require 'json'

class GoogleTopics

    def initialize()
    end

    def getHotTopics()
        return getTopics.first(10)
    end

    def getTopics()
        js = http_get('http://www.google.com/now/en-us.js')
        matches = /nowqueries = (.*);/.match(js)
        if(matches == nil) then
            raise "Unable to parse google topics"
        end
        
        parsed = JSON.parse(matches[1])
        return parsed['queries'].map { |item| item['query'] }
    end
    
    def http_get(url)
        Net::HTTP.get_response(URI.parse(url)).body.to_s
    end

end

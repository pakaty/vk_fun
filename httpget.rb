require 'net/http'
require 'uri'

def get_html_content(req_url) 
	url = URI.parse(req_url)
	h = Net::HTTP.new(url.host, 80)
	return h.get(url.path + "?" + url.query)
end

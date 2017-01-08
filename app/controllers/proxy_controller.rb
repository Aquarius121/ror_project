require "net/http"
require "time"

class ProxyController < ActionController::Base
  layout Proc.new { false }
  
  @@token = ''
  @@expires = 0
  
  def index
    self.initProxy
    isServicable = false
    urls = ['route.arcgis.com', 'elevation.arcgis.com']
    urls.each { |url| isServicable = (@proxyUrl.include?(url) or isServicable) }
    if(isServicable)
      self.run
      render :text => @proxyBody
    else
      render :text => "oops"
    end
  end
  
  def run
    self.useToken
    #omg 0300 here
    req = @proxyUrl.split('?', 2)
    uri = URI.parse(req[0])
    http = Net::HTTP.new(uri.host, uri.port)
    if(@proxyUrl.start_with?('https://'))
      http.use_ssl = true
    end
    if(req.length == 2)
      request_uri = uri.request_uri + "?" + req[1]
    else
      request_uri = uri.request_uri
    end
    
    if(request.post?)
      request = Net::HTTP::Post.new(request_uri)
      request.set_form_data(@proxyData)
    else
      request = Net::HTTP::Get.new(request_uri)
    end
    
    r = http.request(request)
    self.setProxyHeaders(r)
    self.setProxyBody(r)
  end
  
  def useToken
    self.getNewToken
    if (request.post?)
      @proxyData['token'] = @@token
    end
    
    if(request.get?)
      @proxyUrl << "&token=" + @@token 
    end
  end
  
  def initProxy
    @proxyUrl = request.query_string
    if (request.post?)
      @proxyData = request.request_parameters()
    end
  end
    
  def setProxyHeaders(r)
    passThroughHeaders = ["etag", "content-type", "connection", "pragma", "expires", "charset"]
    r.each_header {
      |key, value|
      if(passThroughHeaders.index(key) != nil)
        response.headers[key] = value
      end
    }
    if(false)
      response.content_type = "text/plain"
      response.charset = "utf-8"
    end
  end
  
  def setProxyBody(r)
    @proxyBody = r.body
  end
  
  def getNewToken
    now = Time.now.to_i
    if(@@expires < now)
      uri = URI.parse('https://www.arcgis.com/sharing/oauth2/token')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"client_id" => "uMNmdd47vTRliEUq", "client_secret" => "95b7d49092db480d9cbccab17a463346", "grant_type" => "client_credentials"})
      r = http.request(request)
      answer = ActiveSupport::JSON.decode(r.body)
      @@token = answer["access_token"]
      @@expires = now + answer["expires_in"]
    end
  end
end
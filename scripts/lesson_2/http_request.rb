require 'net/http'
require 'json'

module Lesson2

  class Http

    attr_reader :base_url

    def initialize(host, protocol, auth_cred = nil)
      @base_url ="#{protocol}://#{host}"
      @auth_cred = auth_cred
    end

    def send_request(method, url, headers = nil, params = nil, data = nil)
      uri = URI.parse("#{@base_url}#{url}")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        case method
          when 'GET'
            uri.query = URI.encode_www_form(params) if params
            request = Net::HTTP::Get.new(uri, headers)
          when 'POST'
            request = Net::HTTP::Post.new(uri, headers)
            request.body = data.to_json
          when 'PATCH'
            request = Net::HTTP::Patch.new(uri, headers)
            request.body = data.to_json
          else
            raise "Request type is not defined! Provided type: #{method}"
        end
        request.basic_auth(@auth_cred[:username], @auth_cred[:password]) if @auth_cred
        res = http.request(request)
        raise "Http request failed. Response code is #{res.code}. Error message is #{res.body || 'empty'}" unless res.class == Net::HTTPOK
        Http::handle_result(res.body)
      end
    end

    private

    def self.handle_result(res)
      valid_json?(res) ? JSON.parse(res) : res
    end

    def self.valid_json?(json)
      JSON.parse(json)
      return true
    rescue JSON::ParserError
      return false
    end

  end

end
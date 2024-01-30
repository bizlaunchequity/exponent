# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Exponent
  # This class sends http request to expo server
  class Request
    class << self
      def post(url, body)
        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.instance_of?(URI::HTTPS)
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = body.to_json

        response = http.request(request)

        try_parse_body(response)
      end

      private

      def headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      end

      def try_parse_body(response)
        response.body = JSON.parse(response.body)

        response
      rescue JSON::ParserError
        response
      end
    end
  end
end

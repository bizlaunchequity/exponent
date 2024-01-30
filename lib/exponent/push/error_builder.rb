# frozen_string_literal: true

require_relative "error"

module Exponent
  module Push
    # Class builds errors
    class ErrorBuilder
      def self.parse_response(response)
        case response
        when Net::HTTPBadRequest
          bad_request_error(response)
        else
          unknown_error_format(response)
        end
      end

      def self.too_many_messages(count)
        TooManyMessagesError.new(
          "You can send a maximum of 100 notifications per request (received #{count}); divide your requests."
        )
      end

      def self.bad_request_error(response)
        error = response.body["errors"].first
        message = error["message"]

        case error["code"]
        when "PUSH_TOO_MANY_NOTIFICATIONS"
          TooManyMessagesError.new(message)
        when "VALIDATION_ERROR"
          ValidationError.new(message)
        else
          unknown_error_format(response)
        end
      end
      private_class_method :bad_request_error

      def self.unknown_error_format(response)
        Exponent::Push::UnknownError.new("Unknown error format: #{response.body.inspect}")
      end
      private_class_method :unknown_error_format
    end
  end
end

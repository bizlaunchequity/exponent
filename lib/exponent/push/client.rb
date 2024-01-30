# frozen_string_literal: true

require_relative "error"
require_relative "error_builder"
require_relative "response"
require_relative "../request"

module Exponent
  module Push
    # Class send push notificatios to expo server
    class Client
      def self.send(message)
        message = handle_message(message)

        response = Request.post("https://exp.host/--/api/v2/push/send", message)

        raise ErrorBuilder.parse_response(response) unless response.instance_of?(Net::HTTPOK)

        push_tickets = response.body["data"]

        PushResponse.new(push_tickets)
      end

      def self.verify(receipt_ids)
        response = Request.post("https://exp.host/--/api/v2/push/getReceipts", ids: receipt_ids)

        receipts = response.body["data"]

        VerifyResponse.new(receipts)
      end

      def self.push_token?(token)
        token.match?(/ExponentPushToken\[.{22}\]/)
      end

      def self.handle_message(message)
        case message
        when Array
          handle_array(message)
        when Hash
          validate_message(message)
        else
          raise Error, "Incorect message fromat"
        end
      end
      private_class_method :handle_message

      def self.handle_array(messages)
        messages.each { |message| validate_message(message) }

        message_count = messages.sum do |message|
          message[:to].instance_of?(String) ? 1 : message[:to].length
        end

        raise ErrorBuilder.too_many_messages(message_count) if message_count > 100

        messages
      end
      private_class_method :handle_array

      def self.validate_message(message)
        message.transform_keys!(&:to_sym)

        unless message in {to: Array | String => to, title: String, body: String}
          raise Error, "Incorect message fromat, #{message.inspect}"
        end

        # if to.instance_of?(Array)
        #   to.each { |push_token| raise Error.new("Invalid push token") unless is_push_token?(push_token) }
        # else
        #   raise Error.new("Invalid push token") unless is_push_token?(to)
        # end

        raise ErrorBuilder.too_many_messages(to.length) if to.instance_of?(Array) && to.length > 100

        message
      end
      private_class_method :validate_message
    end
  end
end

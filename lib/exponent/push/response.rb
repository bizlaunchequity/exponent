# frozen_string_literal: true

require_relative "error"

module Exponent
  module Push
    # Basic class for responses
    class Response
      attr_reader :data

      def initialize(data)
        @data = data
      end
    end

    # Class contains response from expo server and provide helpers
    class PushResponse < Response
      def valid_receipt_ids
        case data
        when Array
          data.filter_map do |push_ticket|
            push_ticket["id"] if push_ticket["status"] == "ok"
          end
        when Hash
          data["status"] == "ok" ? [data["id"]] : []
        end
      end

      def invalid_receipt_ids
        data.filter_map do |push_ticket|
          push_ticket["id"] if push_ticket["status"] != "ok"
        end
      end

      def unregestered_push_tokens
        case data
        when Array
          data.filter_map do |push_ticket|
            unregistered_push_token(push_ticket)
          end
        when Hash
          [unregistered_push_token(data)]
        end.compact
      end

      def errors?
        data.any? do |push_ticket|
          push_ticket["status"] != "ok"
        end
      end

      private

      def unregistered_push_token(push_ticket)
        return unless push_ticket["status"] == "error" && push_ticket.dig("details", "error") == "DeviceNotRegistered"

        push_ticket["details"]["expoPushToken"]
      end
    end

    # Class contains response from expo server and provide helpers
    class VerifyResponse < Response
      def delivered_receipt_ids
        data.filter_map do |receipt_id, receipt|
          receipt_id if receipt["status"] == "ok"
        end
      end

      def undelivered_receipt_ids
        data.filter_map do |receipt_id, receipt|
          receipt_id if receipt["status"] != "ok"
        end
      end

      def errors?
        data.any? do |_receipt_id, receipt|
          receipt["status"] != "ok"
        end
      end
    end
  end
end

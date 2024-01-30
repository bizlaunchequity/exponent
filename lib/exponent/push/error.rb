# frozen_string_literal: true

module Exponent
  module Push
    class Error < StandardError
    end

    class TooManyMessagesError < Error
    end

    class DeviceNotRegisteredError < Error
    end

    class ValidationError < Error
    end

    class MessageTooBigError < Error
    end

    class MessageRateExceededError < Error
    end

    class InvalidCredentialsError < Error
    end

    class UnknownError < Error
    end
  end
end

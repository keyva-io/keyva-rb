# frozen_string_literal: true

# Keyva error types.
#
# Auto-generated from keyva protocol spec. Do not edit.

module Keyva
  # Base error for all Keyva operations.
  class Error < StandardError
    attr_reader :code, :detail

    def initialize(code, detail = "")
      @code = code
      @detail = detail
      super("[#{code}] #{detail}")
    end

    # @api private
    def self.from_server(code, detail)
      klass = ERROR_MAP[code] || Error
      klass.new(code, detail)
    end
  end

  # Raised when the underlying TCP connection fails.
  class ConnectionError < Error
    def initialize(msg = "connection error")
      super("CONNECTION", msg)
    end
  end

  # Missing or malformed command argument
  class BadargError < Error; end

  # Refresh token chain limit exceeded
  class ChainLimitError < Error; end

  # Cryptographic operation failed
  class CryptoError < Error; end

  # Authentication required or insufficient permissions
  class DeniedError < Error; end

  # Keyspace is disabled
  class DisabledError < Error; end

  # Credential has expired
  class ExpiredError < Error; end

  # Unexpected internal error
  class InternalError < Error; end

  # Account temporarily locked due to too many failed attempts
  class LockedError < Error; end

  # Credential, keyspace, or resource does not exist
  class NotfoundError < Error; end

  # Server is not ready (still starting up)
  class NotreadyError < Error; end

  # Refresh token reuse detected — family revoked
  class ReuseDetectedError < Error; end

  # Credential is in wrong state for this operation
  class StateErrorError < Error; end

  # Storage engine error
  class StorageError < Error; end

  # Metadata or claims failed schema validation
  class ValidationErrorError < Error; end

  # Operation not supported for this keyspace type
  class WrongtypeError < Error; end

  # @api private
  ERROR_MAP = {
    "BADARG" => BadargError,
    "CHAIN_LIMIT" => ChainLimitError,
    "CRYPTO" => CryptoError,
    "DENIED" => DeniedError,
    "DISABLED" => DisabledError,
    "EXPIRED" => ExpiredError,
    "INTERNAL" => InternalError,
    "LOCKED" => LockedError,
    "NOTFOUND" => NotfoundError,
    "NOTREADY" => NotreadyError,
    "REUSE_DETECTED" => ReuseDetectedError,
    "STATE_ERROR" => StateErrorError,
    "STORAGE" => StorageError,
    "VALIDATION_ERROR" => ValidationErrorError,
    "WRONGTYPE" => WrongtypeError,
  }.freeze
end

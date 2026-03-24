# frozen_string_literal: true

# Internal Keyva protocol codec.
#
# This class is an implementation detail. Use Keyva::Client instead.
#
# Auto-generated from keyva protocol spec. Do not edit.

require "socket"
require "openssl"

module Keyva
  # @api private
  class Connection
    def initialize(socket)
      @socket = socket
    end

    def self.open(host, port, tls: false)
      sock = TCPSocket.new(host, port)
      if tls
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)
        ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
        ssl.hostname = host
        ssl.connect
        sock = ssl
      end
      new(sock)
    end

    def execute(*args)
      # Encode command
      cmd = "*#{args.length}\r\n"
      args.each do |arg|
        s = arg.to_s
        cmd << "$#{s.bytesize}\r\n#{s}\r\n"
      end
      @socket.write(cmd)
      read_frame
    end

    def close
      @socket.close
    rescue IOError
      # already closed
    end

    private

    def read_frame
      line = @socket.gets("\r\n")
      raise Keyva::ConnectionError, "Connection closed" if line.nil?

      tag = line[0]
      payload = line[1..-3] # strip \r\n

      case tag
      when "+"
        payload
      when "-"
        code, message = payload.split(" ", 2)
        raise Keyva::Error.from_server(code, message || "")
      when ":"
        payload.to_i
      when "$"
        len = payload.to_i
        return nil if len < 0

        data = @socket.read(len + 2) # +2 for \r\n
        data[0...len]
      when "*"
        count = payload.to_i
        Array.new(count) { read_frame }
      when "%"
        count = payload.to_i
        hash = {}
        count.times do
          key = read_frame
          val = read_frame
          hash[key.to_s] = val
        end
        hash
      when "_"
        nil
      else
        raise Keyva::Error.new("INTERNAL", "Unknown response type: #{tag}")
      end
    end
  end
end

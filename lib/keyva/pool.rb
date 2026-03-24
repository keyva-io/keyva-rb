# frozen_string_literal: true

# Connection pool for Keyva clients.
#
# Auto-generated from keyva protocol spec. Do not edit.

module Keyva
  # @api private
  class Pool
    # @param host [String]
    # @param port [Integer]
    # @param tls [Boolean]
    # @param auth [String, nil]
    # @param max_idle [Integer] maximum idle connections (default: 4)
    # @param max_open [Integer] maximum total connections, 0 = unlimited (default: 0)
    def initialize(host:, port:, tls: false, auth: nil, max_idle: 4, max_open: 0)
      @host = host
      @port = port
      @tls = tls
      @auth = auth
      @max_idle = max_idle
      @max_open = max_open
      @idle = []
      @open = 0
      @mutex = Mutex.new
    end

    def get
      @mutex.synchronize do
        if (conn = @idle.pop)
          return conn
        end

        @open += 1
      end

      conn = Connection.open(@host, @port, tls: @tls)
      conn.execute("AUTH", @auth) if @auth
      conn
    rescue StandardError
      @mutex.synchronize { @open -= 1 }
      raise
    end

    def put(conn)
      @mutex.synchronize do
        if @idle.length < @max_idle
          @idle.push(conn)
        else
          conn.close
          @open -= 1
        end
      end
    end

    def close
      @mutex.synchronize do
        @idle.each(&:close)
        @idle.clear
        @open = 0
      end
    end
  end
end

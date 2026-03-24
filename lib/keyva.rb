# frozen_string_literal: true

# Keyva — Ruby client for the Keyva Credential management server.
#
# Auto-generated from keyva protocol spec. Do not edit.
#
# Usage:
#
#   client = Keyva::Client.connect("keyva://://localhost")
#   result = client.issue("my-keyspace", ttl: 3600)
#   puts result.credential_id, result.token
#   client.close

require_relative "keyva/errors"
require_relative "keyva/types"
require_relative "keyva/connection"
require_relative "keyva/pool"
require_relative "keyva/client"

module Keyva
  VERSION = "0.1.0"
  DEFAULT_PORT = 6399
end

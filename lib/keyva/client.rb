# frozen_string_literal: true

# Keyva client.
#
# Auto-generated from keyva protocol spec. Do not edit.

require "json"
require "uri"

module Keyva
  # Client for the Keyva Credential management server.
  #
  # Connect using a Keyva URI:
  #
  #   client = Keyva::Client.connect("keyva://://localhost")
  #   result = client.issue("my-keyspace", ttl: 3600)
  #   puts result.credential_id, result.token
  #   client.close
  #
  #   # With TLS and auth:
  #   client = Keyva::Client.connect("keyva://+tls://mytoken@prod.example.com/keys")
  #
  class Client
    # Connect to a Keyva server.
    #
    # @param uri [String] Keyva connection URI
    #   Format: +keyva://://[token@]host[:port][/keyspace]+
    #   or +keyva://+tls://[token@]host[:port][/keyspace]+
    # @param max_idle [Integer] max idle connections in pool (default: 4)
    # @param max_open [Integer] max total connections, 0 = unlimited (default: 0)
    # @return [Client]
    def self.connect(uri = "keyva://://localhost", max_idle: 4, max_open: 0)
      cfg = parse_uri(uri)
      pool = Pool.new(
        host: cfg[:host],
        port: cfg[:port],
        tls: cfg[:tls],
        auth: cfg[:auth_token],
        max_idle: max_idle,
        max_open: max_open
      )
      new(pool)
    end

    # Close the client and all pooled connections.
    def close
      @pool.close
    end

    # Authenticate the current connection
    # @param token [String] Authentication token
    def auth(token)
      args = []
      args.push("AUTH")
      args.push(token.to_s)
      result = exec(*args)
    end

    # Retrieve a runtime configuration value
    # @param key [String] Configuration key name
    # @return [ConfigGetResponse]
    def config_get(key)
      args = []
      args.push("CONFIG", "GET")
      args.push(key.to_s)
      result = exec(*args)
      ConfigGetResponse.new(value: result["value"])
    end

    # Set a runtime configuration value
    # @param key [String] Configuration key name
    # @param value [String] New value
    def config_set(key, value)
      args = []
      args.push("CONFIG", "SET")
      args.push(key.to_s)
      args.push(value.to_s)
      result = exec(*args)
    end

    # Check server or keyspace health
    # @param keyspace [String] Check a specific keyspace (omit for server-level)
    # @return [HealthResponse]
    def health(keyspace: nil)
      args = []
      args.push("HEALTH")
      args.push(keyspace.to_s) unless keyspace.nil?
      result = exec(*args)
      HealthResponse.new(state: result["state"], keyspaces: result["keyspaces"], count: result["count"])
    end

    # Retrieve full details about a credential
    # @param keyspace [String] Target keyspace name
    # @param credential_id [String] Credential to inspect
    # @return [InspectResponse]
    def inspect(keyspace, credential_id)
      args = []
      args.push("INSPECT")
      args.push(keyspace.to_s)
      args.push(credential_id.to_s)
      result = exec(*args)
      InspectResponse.new(credential_id: result["credential_id"], state: result["state"], created_at: result["created_at"], expires_at: result["expires_at"], last_verified_at: result["last_verified_at"], meta: result["meta"], family_id: result["family_id"])
    end

    # Issue a new credential in the given keyspace
    # @param keyspace [String] Target keyspace name
    # @param claims [Hash] JWT claims object (JWT keyspaces only)
    # @param metadata [Hash] Metadata to attach to the credential
    # @param ttl_secs [Integer] Time-to-live in seconds
    # @param idempotency_key [String] Prevents duplicate issuance within 5 min
    # @return [IssueResponse]
    def issue(keyspace, claims: nil, metadata: nil, ttl_secs: nil, idempotency_key: nil)
      args = []
      args.push("ISSUE")
      args.push(keyspace.to_s)
      unless claims.nil?
        args.push("CLAIMS", JSON.generate(claims))
      end
      unless metadata.nil?
        args.push("META", JSON.generate(metadata))
      end
      unless ttl_secs.nil?
        args.push("TTL", ttl_secs.to_s)
      end
      unless idempotency_key.nil?
        args.push("IDEMPOTENCY_KEY", idempotency_key.to_s)
      end
      result = exec(*args)
      IssueResponse.new(credential_id: result["credential_id"], token: result["token"], expires_at: result["expires_at"], family_id: result["family_id"])
    end

    # Return the JSON Web Key Set for a JWT keyspace
    # @param keyspace [String] Target JWT keyspace
    # @return [JwksResponse]
    def jwks(keyspace)
      args = []
      args.push("JWKS")
      args.push(keyspace.to_s)
      result = exec(*args)
      JwksResponse.new(jwks: result["jwks"])
    end

    # List credential IDs with optional filtering and pagination
    # @param keyspace [String] Target keyspace name
    # @param cursor [String] Resume from a previous scan cursor
    # @param pattern [String] Glob-style pattern to filter credential IDs
    # @param state_filter [String] Filter by state: active, suspended, revoked
    # @param count [Integer] Max results to return (default: 100)
    # @return [KeysResponse]
    def keys(keyspace, cursor: nil, pattern: nil, state_filter: nil, count: nil)
      args = []
      args.push("KEYS")
      args.push(keyspace.to_s)
      unless cursor.nil?
        args.push("CURSOR", cursor.to_s)
      end
      unless pattern.nil?
        args.push("MATCH", pattern.to_s)
      end
      unless state_filter.nil?
        args.push("STATE", state_filter.to_s)
      end
      unless count.nil?
        args.push("COUNT", count.to_s)
      end
      result = exec(*args)
      KeysResponse.new(cursor: result["cursor"], keys: result["keys"])
    end

    # Show the current key ring state for a keyspace
    # @param keyspace [String] Target keyspace
    # @return [KeystateResponse]
    def keystate(keyspace)
      args = []
      args.push("KEYSTATE")
      args.push(keyspace.to_s)
      result = exec(*args)
      KeystateResponse.new(keys: result["keys"])
    end

    # Change a user's password (requires old password)
    # @param keyspace [String] Target password keyspace
    # @param user_id [String] User identifier
    # @param old_password [String] Current plaintext password
    # @param new_password [String] New plaintext password
    # @return [PasswordChangeResponse]
    def password_change(keyspace, user_id, old_password, new_password)
      args = []
      args.push("PASSWORD", "CHANGE")
      args.push(keyspace.to_s)
      args.push(user_id.to_s)
      args.push(old_password.to_s)
      args.push(new_password.to_s)
      result = exec(*args)
      PasswordChangeResponse.new(credential_id: result["credential_id"], updated_at: result["updated_at"])
    end

    # Import a pre-hashed password for migration from another system (argon2, bcrypt, scrypt)
    # @param keyspace [String] Target password keyspace
    # @param user_id [String] User identifier
    # @param hash [String] Pre-hashed password string (PHC or modular crypt format)
    # @param metadata [Hash] Metadata to attach to the credential
    # @return [PasswordImportResponse]
    def password_import(keyspace, user_id, hash, metadata: nil)
      args = []
      args.push("PASSWORD", "IMPORT")
      args.push(keyspace.to_s)
      args.push(user_id.to_s)
      args.push(hash.to_s)
      unless metadata.nil?
        args.push("META", JSON.generate(metadata))
      end
      result = exec(*args)
      PasswordImportResponse.new(credential_id: result["credential_id"], user_id: result["user_id"], algorithm: result["algorithm"], created_at: result["created_at"])
    end

    # Set a password for a user in a password keyspace
    # @param keyspace [String] Target password keyspace
    # @param user_id [String] User identifier
    # @param password [String] Plaintext password (never stored)
    # @param metadata [Hash] Metadata to attach to the credential
    # @return [PasswordSetResponse]
    def password_set(keyspace, user_id, password, metadata: nil)
      args = []
      args.push("PASSWORD", "SET")
      args.push(keyspace.to_s)
      args.push(user_id.to_s)
      args.push(password.to_s)
      unless metadata.nil?
        args.push("META", JSON.generate(metadata))
      end
      result = exec(*args)
      PasswordSetResponse.new(credential_id: result["credential_id"], user_id: result["user_id"], algorithm: result["algorithm"], created_at: result["created_at"])
    end

    # Verify a user's password
    # @param keyspace [String] Target password keyspace
    # @param user_id [String] User identifier
    # @param password [String] Plaintext password to verify
    # @return [PasswordVerifyResponse]
    def password_verify(keyspace, user_id, password)
      args = []
      args.push("PASSWORD", "VERIFY")
      args.push(keyspace.to_s)
      args.push(user_id.to_s)
      args.push(password.to_s)
      result = exec(*args)
      PasswordVerifyResponse.new(valid: result["valid"], credential_id: result["credential_id"], metadata: result["metadata"])
    end

    # Exchange a refresh token for a new one
    # @param keyspace [String] Target keyspace name
    # @param token [String] Current refresh token
    # @return [RefreshResponse]
    def refresh(keyspace, token)
      args = []
      args.push("REFRESH")
      args.push(keyspace.to_s)
      args.push(token.to_s)
      result = exec(*args)
      RefreshResponse.new(credential_id: result["credential_id"], token: result["token"], family_id: result["family_id"], expires_at: result["expires_at"])
    end

    # Revoke a credential by ID
    # @param keyspace [String] Target keyspace name
    # @param credential_id [String] Credential to revoke
    # @return [RevokeResponse]
    def revoke(keyspace, credential_id)
      args = []
      args.push("REVOKE")
      args.push(keyspace.to_s)
      args.push(credential_id.to_s)
      result = exec(*args)
      RevokeResponse.new(revoked: result["revoked"])
    end

    # Bulk-revoke multiple credentials
    # @param keyspace [String] Target keyspace name
    # @param ids [String] Credential IDs to revoke
    # @return [RevokeBulkResponse]
    def revoke_bulk(keyspace, ids: nil)
      args = []
      args.push("REVOKE")
      args.push(keyspace.to_s)
      unless ids.nil? || ids.empty?
        args.push("BULK")
        args.concat(ids.map(&:to_s))
      end
      result = exec(*args)
      RevokeBulkResponse.new(revoked: result["revoked"])
    end

    # Revoke all credentials in a refresh token family
    # @param keyspace [String] Target keyspace name
    # @param family_id [String] Family ID to revoke
    # @return [RevokeFamilyResponse]
    def revoke_family(keyspace, family_id: nil)
      args = []
      args.push("REVOKE")
      args.push(keyspace.to_s)
      unless family_id.nil?
        args.push("FAMILY", family_id.to_s)
      end
      result = exec(*args)
      RevokeFamilyResponse.new(revoked: result["revoked"])
    end

    # Trigger signing key rotation for a keyspace
    # @param keyspace [String] Target keyspace name
    # @param force [Boolean] Rotate even if current key has not reached rotation age
    # @param nowait [Boolean] Return immediately without waiting
    # @param dryrun [Boolean] Preview without making changes
    # @return [RotateResponse]
    def rotate(keyspace, force: false, nowait: false, dryrun: false)
      args = []
      args.push("ROTATE")
      args.push(keyspace.to_s)
      args.push("FORCE") if force
      args.push("NOWAIT") if nowait
      args.push("DRYRUN") if dryrun
      result = exec(*args)
      RotateResponse.new(new_key_id: result["new_key_id"], old_key_id: result["old_key_id"], dryrun: result["dryrun"])
    end

    # Display the metadata schema for a keyspace
    # @param keyspace [String] Target keyspace
    # @return [SchemaResponse]
    def schema(keyspace)
      args = []
      args.push("SCHEMA")
      args.push(keyspace.to_s)
      result = exec(*args)
      SchemaResponse.new(schema: result["schema"])
    end

    # subscribe is not yet supported (requires streaming).

    # Temporarily suspend a credential
    # @param keyspace [String] Target keyspace name
    # @param credential_id [String] Credential to suspend
    def suspend(keyspace, credential_id)
      args = []
      args.push("SUSPEND")
      args.push(keyspace.to_s)
      args.push(credential_id.to_s)
      result = exec(*args)
    end

    # Reactivate a previously suspended credential
    # @param keyspace [String] Target keyspace name
    # @param credential_id [String] Credential to unsuspend
    def unsuspend(keyspace, credential_id)
      args = []
      args.push("UNSUSPEND")
      args.push(keyspace.to_s)
      args.push(credential_id.to_s)
      result = exec(*args)
    end

    # Update metadata on an existing credential
    # @param keyspace [String] Target keyspace name
    # @param credential_id [String] Credential to update
    # @param metadata [Hash] Metadata fields to merge
    def update(keyspace, credential_id, metadata: nil)
      args = []
      args.push("UPDATE")
      args.push(keyspace.to_s)
      args.push(credential_id.to_s)
      unless metadata.nil?
        args.push("META", JSON.generate(metadata))
      end
      result = exec(*args)
    end

    # Verify a credential (JWT, API key, or HMAC signature)
    # @param keyspace [String] Target keyspace name
    # @param token [String] The token/key/signature to verify
    # @param payload [String] Original message for HMAC verification
    # @param check_revoked [Boolean] Also check the revocation index
    # @return [VerifyResponse]
    def verify(keyspace, token, payload: nil, check_revoked: false)
      args = []
      args.push("VERIFY")
      args.push(keyspace.to_s)
      args.push(token.to_s)
      unless payload.nil?
        args.push("PAYLOAD", payload.to_s)
      end
      args.push("CHECKREV") if check_revoked
      result = exec(*args)
      VerifyResponse.new(credential_id: result["credential_id"], claims: result["claims"], meta: result["meta"], state: result["state"])
    end

    private

    def initialize(pool)
      @pool = pool
    end

    def exec(*args)
      conn = @pool.get
      result = conn.execute(*args)
      @pool.put(conn)
      result
    rescue StandardError
      conn&.close
      raise
    end

    def self.parse_uri(uri)
      tls = false
      if uri.start_with?("keyva://+tls://")
        tls = true
        uri = "keyva://://#{uri[15..]}"

      elsif !uri.start_with?("keyva://://")
        raise Keyva::Error.new("BADARG", "Invalid Keyva URI: #{uri}  (expected keyva://:// or keyva://+tls://)")
      end

      parsed = URI.parse(uri)
      {
        host: parsed.host || "localhost",
        port: parsed.port || DEFAULT_PORT,
        tls: tls,
        auth_token: parsed.user,
        keyspace: parsed.path&.delete_prefix("/")&.then { |s| s.empty? ? nil : s }
      }
    end
  end
end

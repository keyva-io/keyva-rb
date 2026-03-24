# frozen_string_literal: true

# Keyva response types.
#
# Auto-generated from keyva protocol spec. Do not edit.

module Keyva
  # Response from CONFIG command.
  ConfigGetResponse = Struct.new(:value, keyword_init: true)

  # Response from HEALTH command.
  HealthResponse = Struct.new(:state, :keyspaces, :count, keyword_init: true)

  # Response from INSPECT command.
  InspectResponse = Struct.new(:credential_id, :state, :created_at, :expires_at, :last_verified_at, :meta, :family_id, keyword_init: true)

  # Response from ISSUE command.
  IssueResponse = Struct.new(:credential_id, :token, :expires_at, :family_id, keyword_init: true)

  # Response from JWKS command.
  JwksResponse = Struct.new(:jwks, keyword_init: true)

  # Response from KEYS command.
  KeysResponse = Struct.new(:cursor, :keys, keyword_init: true)

  # Response from KEYSTATE command.
  KeystateResponse = Struct.new(:keys, keyword_init: true)

  # Response from PASSWORD command.
  PasswordChangeResponse = Struct.new(:credential_id, :updated_at, keyword_init: true)

  # Response from PASSWORD command.
  PasswordImportResponse = Struct.new(:credential_id, :user_id, :algorithm, :created_at, keyword_init: true)

  # Response from PASSWORD command.
  PasswordSetResponse = Struct.new(:credential_id, :user_id, :algorithm, :created_at, keyword_init: true)

  # Response from PASSWORD command.
  PasswordVerifyResponse = Struct.new(:valid, :credential_id, :metadata, keyword_init: true)

  # Response from REFRESH command.
  RefreshResponse = Struct.new(:credential_id, :token, :family_id, :expires_at, keyword_init: true)

  # Response from REVOKE command.
  RevokeResponse = Struct.new(:revoked, keyword_init: true)

  # Response from REVOKE command.
  RevokeBulkResponse = Struct.new(:revoked, keyword_init: true)

  # Response from REVOKE command.
  RevokeFamilyResponse = Struct.new(:revoked, keyword_init: true)

  # Response from ROTATE command.
  RotateResponse = Struct.new(:new_key_id, :old_key_id, :dryrun, keyword_init: true)

  # Response from SCHEMA command.
  SchemaResponse = Struct.new(:schema, keyword_init: true)

  # Response from VERIFY command.
  VerifyResponse = Struct.new(:credential_id, :claims, :meta, :state, keyword_init: true)

end

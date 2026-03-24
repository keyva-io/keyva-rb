# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "keyva"
  s.version     = "0.1.0"
  s.summary     = "Ruby client for the Keyva Credential management server"
  s.description = "Typed Ruby client for Keyva. Connects via keyva://:// URI, manages credentials via the Keyva protocol."
  s.license     = "MIT"
  s.authors     = ["Keyva"]
  s.files       = Dir["lib/**/*.rb"]
  s.required_ruby_version = ">= 3.1"
end

# frozen_string_literal: true

module Identifiable
  class Configuration
    # Hashid configuration
    attr_accessor :hashid_salt, :hashid_min_length, :hashid_alphabet

    # Base62 alphabet for UUID encoding
    attr_accessor :base62_alphabet

    # Separator between prefix and hash
    attr_accessor :separator

    # Whether to include the prefix in to_param URLs
    # true = /users/usr_k5qx9z (Stripe style)
    # false = /users/k5qx9z (cleaner)
    attr_accessor :use_prefix_in_routes

    def initialize
      @hashid_salt = nil # Will fall back to Rails.application.secret_key_base
      @hashid_min_length = 8
      @hashid_alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
      @base62_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      @separator = "_"
      @use_prefix_in_routes = false
    end
  end
end

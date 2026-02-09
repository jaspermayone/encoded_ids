# frozen_string_literal: true

# Example configuration for config/initializers/encoded_ids.rb
#
# Copy this file to your Rails app's config/initializers/ directory
# and customize as needed.

EncodedIds.configure do |config|
  # Hashid configuration (for integer IDs)
  # IMPORTANT: Set a unique salt in production via credentials
  # rails credentials:edit
  # Add: hashid: { salt: "your-unique-salt-here" }
  config.hashid_salt = Rails.application.credentials.dig(:hashid, :salt)
  config.hashid_min_length = 8
  config.hashid_alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"

  # Base62 alphabet (for UUID encoding)
  # Standard base62 includes both uppercase and lowercase
  config.base62_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  # Separator between prefix and hash
  # Default is "_" for Stripe-style IDs like "usr_abc123"
  # You could use "-" for "usr-abc123" or any other character
  config.separator = "_"

  # Whether to include prefix in to_param URLs
  # false (default) = /users/k5qx9z (cleaner)
  # true = /users/usr_k5qx9z (Stripe style - redundant with route path)
  config.use_prefix_in_routes = false
end

# frozen_string_literal: true

# Example model configurations

# Integer primary key with simple prefix
class User < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :usr
end
# user.public_id => "usr_k5qx9z"
# user.to_param => "k5qx9z" (no prefix in URLs by default)

# Integer primary key with longer hash for high-volume tables
class Event < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :evt, min_hash_length: 12
end
# event.public_id => "evt_x5qp9z2m8n4k"

# Integer primary key with compositional prefix
class Intel::Tool::PhoneNumber < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  add_public_id_segment :int
  add_public_id_segment :tool
  add_public_id_segment :phn
end
# phone.public_id => "int_tool_phn_k5qx9z"

# UUID primary key
class Organization < ApplicationRecord
  include EncodedIds::UuidIdentifiable
  set_public_id_prefix "org"
end
# org.public_id => "org_4k8xJm2pN9qW"

# UUID primary key with different prefix
class Team < ApplicationRecord
  include EncodedIds::UuidIdentifiable
  set_public_id_prefix "team"
end
# team.public_id => "team_7n2kLp4xMq8R"

# Override per-model to include prefix in routes (Stripe style)
class ApiKey < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :key, use_prefix_in_routes: true
end
# api_key.public_id => "key_abc123"
# api_key.to_param => "key_abc123" (includes prefix)

# Security: Custom salt for specific model
class SecureDocument < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :doc, salt: Rails.application.credentials.dig(:documents, :salt)
end
# Uses a different salt than the global default for added security

# Security: Empty salt for backward compatibility with legacy IDs
class LegacyUser < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :leg, salt: ""
end
# Maintains compatibility with existing hash IDs generated without a salt

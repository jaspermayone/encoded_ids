# EncodedIds

Stripe-like public IDs for Rails models. Generate API-friendly identifiers like `usr_k5qx9z` or `org_4k8xJm2pN9qW` that:

- Hide sequential integer IDs from your API
- Provide type context in the ID itself (the prefix tells you it's a user, organization, etc.)
- Work seamlessly with Rails routing and controllers
- Support both integer and UUID primary keys

## Installation

Add to your Gemfile:

```ruby
gem 'encoded_ids'
```

Or install directly:

```bash
gem install encoded_ids
```

## Quick Start

### For models with integer IDs (uses hashids):

```ruby
class User < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :usr
end

user = User.first
user.public_id        # => "usr_k5qx9z"
user.to_param         # => "k5qx9z" (used in URLs - no prefix by default)

# Find by public_id (with or without prefix)
User.find("k5qx9z")                   # => <User id: 1>
User.find("usr_k5qx9z")               # => <User id: 1>
User.find_by_public_id("usr_k5qx9z")  # => <User id: 1>
```

### For models with UUID IDs (uses base62 encoding):

```ruby
class Organization < ApplicationRecord
  include EncodedIds::UuidIdentifiable
  set_public_id_prefix "org"
end

org = Organization.first
org.public_id   # => "org_4k8xJm2pN9qW"
org.to_param    # => "4k8xJm2pN9qW" (no prefix by default)

# Find by public_id (with or without prefix)
Organization.find("4k8xJm2pN9qW")                   # => <Organization id: "uuid...">
Organization.find("org_4k8xJm2pN9qW")               # => <Organization id: "uuid...">
Organization.find_by_public_id("org_4k8xJm2pN9qW")  # => <Organization id: "uuid...">
```

## Features

### Automatic URL Parameter Handling

The gem overrides `to_param` automatically, so Rails will use the hashid/encoded ID in all your URLs:

```ruby
link_to "View User", user_path(user)
# => /users/k5qx9z (clean URLs without prefix by default)

redirect_to @user
# => /users/k5qx9z

# You can still use the full public_id with prefix if needed:
User.find_by_public_id("usr_k5qx9z")  # Works!
```

### Overridden `find` Method

The `find` method is automatically enhanced to accept internal IDs, hashids, and full public IDs:

```ruby
# These all work:
User.find(1)              # Regular internal ID
User.find("k5qx9z")       # Hashid (no prefix)
User.find("usr_k5qx9z")   # Full public ID (with prefix)
```

### Compositional Prefixes (Hashid only)

For namespaced models, you can build prefixes from multiple segments:

```ruby
class Intel::Tool::PhoneNumber < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  add_public_id_segment :int
  add_public_id_segment :tool
  add_public_id_segment :phn
end

phone.public_id  # => "int_tool_phn_k5qx9z"
```

### Configurable Hash Length

For tables with many records, increase the minimum hash length:

```ruby
class Enrollment < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :enr, min_hash_length: 12
end

enrollment.public_id  # => "enr_x5qp9z2m8n4k"
enrollment.to_param   # => "x5qp9z2m8n4k"
```

### Route Behavior Configuration

By default, `to_param` returns just the hash (no prefix) for cleaner URLs. You can change this globally or per-model:

```ruby
# Global configuration - include prefix in all URLs (Stripe style)
EncodedIds.configure do |config|
  config.use_prefix_in_routes = true
end

# Per-model override
class User < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :usr, use_prefix_in_routes: true
end

user.to_param  # => "usr_k5qx9z" instead of just "k5qx9z"
```

### Controller Helpers

Automatically included in all controllers:

```ruby
class UsersController < ApplicationController
  def show
    # Accepts both internal ID and public_id
    @user = find_by_any_id(User, params[:id])

    # Or with bang method (raises RecordNotFound)
    @user = find_by_any_id!(User, params[:id])
  end
end
```

## Configuration

Create an initializer at `config/initializers/encoded_ids.rb`:

```ruby
EncodedIds.configure do |config|
  # Hashid configuration (for integer IDs)
  # SECURITY IMPORTANT: Set a unique salt! See Security section below.
  config.hashid_salt = Rails.application.credentials.dig(:hashid, :salt) || ENV["HASHID_SALT"]
  config.hashid_min_length = 8
  config.hashid_alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"

  # Base62 alphabet (for UUID encoding)
  config.base62_alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  # Separator between prefix and hash
  config.separator = "_"

  # Whether to include prefix in to_param URLs
  # false (default) = /users/k5qx9z
  # true = /users/usr_k5qx9z (Stripe style)
  config.use_prefix_in_routes = false
end
```

### Security: Configuring Your Salt

**IMPORTANT:** Without a unique salt, hash IDs can be calculated by anyone who knows your database IDs, making them only marginally better than exposing raw IDs.

The gem uses a fallback chain for the salt:
1. `EncodedIds.configuration.hashid_salt` (set in initializer)
2. `Rails.application.credentials.dig(:hashid, :salt)` (recommended)
3. `ENV["HASHID_SALT"]`
4. `Rails.application.secret_key_base` (not recommended - shows warning in development)

**Recommended setup:**

```bash
# Generate a unique salt
rails credentials:edit
```

Add to your credentials:
```yaml
hashid:
  salt: <paste output of: SecureRandom.hex(32)>  # e.g., "a1b2c3d4e5f6..."
```

The initializer will automatically pick it up:
```ruby
config.hashid_salt = Rails.application.credentials.dig(:hashid, :salt)
```

**Per-model salt override:**

For models that need different salts (e.g., to maintain compatibility with legacy IDs):

```ruby
class LegacyUser < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :usr, salt: "" # Empty salt for backward compatibility
end

class SecureDocument < ApplicationRecord
  include EncodedIds::HashidIdentifiable
  set_public_id_prefix :doc, salt: Rails.application.credentials.dig(:documents, :salt)
end
```

## How It Works

### Integer IDs (HashidIdentifiable)

Uses [hashid-rails](https://github.com/jcypret/hashid-rails) to encode integer IDs into short, URL-safe strings. The encoding is:
- Reversible (can decode back to the integer ID)
- Obfuscated (not sequential, not easily guessable)
- Short (configurable minimum length)

### UUID IDs (UuidIdentifiable)

Uses base62 encoding to shorten UUIDs from 36 characters to ~22 characters. Since UUIDs are already random and non-sequential, this just adds the prefix and shortens the representation.

## API

### Model Methods (both types)

```ruby
# Instance methods
model.public_id         # Returns the full public ID
model.to_param          # Returns the public ID (used by Rails in URLs)

# Class methods
Model.find(id)                    # Accepts both internal and public IDs
Model.find_by_public_id(id)       # Only finds by public ID
Model.find_by_public_id!(id)      # Like above, but raises if not found
Model.get_public_id_prefix        # Returns the configured prefix
```

### Controller Methods

```ruby
find_by_any_id(Model, id)   # Returns record or nil
find_by_any_id!(Model, id)  # Returns record or raises RecordNotFound
```

## Migration from Existing Code

If you have existing `PublicIdentifiable` concerns in your app:

1. Add `encoded_ids` to your Gemfile
2. Replace `include PublicIdentifiable` with:
   - `include EncodedIds::HashidIdentifiable` (for integer IDs)
   - `include EncodedIds::UuidIdentifiable` (for UUID IDs)
3. Update your hashid initializer to use `EncodedIds.configure`
4. Remove your old `PublicIdentifiable` concern
5. Controllers automatically get the helper methods

## Why Public IDs?

Public IDs provide several benefits:

1. **Security**: Don't expose sequential integer IDs that leak information about your data volume
2. **Type Safety**: The prefix makes it obvious what type of resource an ID refers to
3. **API Ergonomics**: Easier to debug and understand API calls
4. **Future-Proofing**: Can change internal IDs without breaking external APIs

Inspired by Stripe's API design and the [hashid-rails](https://github.com/jcypret/hashid-rails) gem, as well as my time at Hack Club which used a base version of this extensively.

## License

MIT

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaspermayone/encoded_ids

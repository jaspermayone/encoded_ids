# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-12

### Added
- Per-model salt override support via `salt:` parameter in `set_public_id_prefix`
- Environment variable support (`ENV["HASHID_SALT"]`) in salt fallback chain
- Development warning when no custom salt is configured
- Enhanced security documentation in README
- Security examples in models.rb showing salt override patterns

### Changed
- Improved salt fallback chain: config → credentials → ENV → secret_key_base
- Enhanced initializer example with better security guidance
- Updated documentation to emphasize importance of using a unique salt

### Security
- **IMPORTANT**: Without a unique salt, hash IDs can be calculated by anyone who knows your database IDs
- Per-model salts allow for better security isolation between models
- Empty salt option (`salt: ""`) available for backward compatibility with legacy systems

## [1.0.0] - 2026-02-09

### Added
- Initial stable release
- `HashidIdentifiable` concern for integer primary keys
- `UuidIdentifiable` concern for UUID primary keys
- Automatic `to_param` override for Rails URL generation
- Overridden `find` method to accept both internal and public IDs
- `find_by_public_id` and `find_by_public_id!` class methods
- Controller helpers: `find_by_any_id` and `find_by_any_id!`
- Compositional prefix support with `add_public_id_segment`
- Configurable hash length for hashids
- Global configuration via `EncodedIds.configure`
- Automatic Rails integration via Railtie

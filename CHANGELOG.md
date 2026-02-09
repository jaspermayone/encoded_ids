# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-09

### Added
- Initial stable release
- `HashidEncodedIds` concern for integer primary keys
- `UuidEncodedIds` concern for UUID primary keys
- Automatic `to_param` override for Rails URL generation
- Overridden `find` method to accept both internal and public IDs
- `find_by_public_id` and `find_by_public_id!` class methods
- Controller helpers: `find_by_any_id` and `find_by_any_id!`
- Compositional prefix support with `add_public_id_segment`
- Configurable hash length for hashids
- Global configuration via `EncodedIds.configure`
- Automatic Rails integration via Railtie

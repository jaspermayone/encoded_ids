# frozen_string_literal: true

require_relative "lib/identifiable/version"

Gem::Specification.new do |spec|
  spec.name = "identifiable"
  spec.version = Identifiable::VERSION
  spec.authors = ["Jasper Mayone"]
  spec.email = ["me@jaspermayone.com"]

  spec.summary = "Stripe-like public IDs for Rails models"
  spec.description = "Provides Stripe-style public identifiers (like usr_abc123) for Rails models using hashids or base62 encoding. Supports both integer and UUID primary keys, with automatic URL parameter handling and controller helpers."
  spec.homepage = "https://github.com/jaspermayone/identifiable"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.1"
  spec.add_dependency "hashid-rails", "~> 1.0"
end

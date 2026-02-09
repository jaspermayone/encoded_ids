# frozen_string_literal: true

module Identifiable
  # PublicIdentifiable for models with UUID primary keys using base62 encoding
  #
  # Since UUIDs are already non-sequential and random, this focuses on:
  # 1. Adding a type prefix for easy identification
  # 2. Shortening the ID for better URL/API ergonomics
  # 3. Maintaining bi-directional conversion (public_id <-> UUID)
  #
  # Usage:
  #   class User < ApplicationRecord
  #     include Identifiable::UuidIdentifiable
  #     set_public_id_prefix "usr"
  #   end
  #
  #   user.public_id          # => "usr_4k8xJm2pN9qW"
  #   User.find_by_public_id("usr_4k8xJm2pN9qW")  # => User instance
  #
  module UuidIdentifiable
    extend ActiveSupport::Concern

    included do
      class_attribute :public_id_prefix, default: nil
      class_attribute :use_prefix_in_routes, default: nil
    end

    # Returns the full public ID with prefix
    def public_id
      prefix = self.class.get_public_id_prefix
      encoded = self.class.encode_uuid(id)
      "#{prefix}#{separator}#{encoded}"
    end

    # Returns just the encoded UUID (without prefix) for use in URLs
    def encoded_id
      self.class.encode_uuid(id)
    end

    # Override to_param for Rails URL generation
    # Respects use_prefix_in_routes configuration
    def to_param
      use_prefix = self.class.use_prefix_in_routes.nil? ?
        Identifiable.configuration.use_prefix_in_routes :
        self.class.use_prefix_in_routes

      use_prefix ? public_id : encoded_id
    end

    def separator
      Identifiable.configuration.separator
    end

    # Alias for Rails conventions
    alias_method :to_public_param, :public_id

    class_methods do
      # Set the prefix for this model's public IDs
      def set_public_id_prefix(prefix, use_prefix_in_routes: nil)
        self.public_id_prefix = prefix.to_s.freeze
        self.use_prefix_in_routes = use_prefix_in_routes
      end

      # Get the configured prefix, with validation
      def get_public_id_prefix
        raise "Public ID prefix not set for #{name}. Call set_public_id_prefix in your model." if public_id_prefix.blank?
        public_id_prefix
      end

      # Find by public_id, encoded UUID, or regular UUID
      def find(*args)
        id = args.first

        # If it's a public_id string (with prefix), find by public_id
        if id.is_a?(String) && id.include?(Identifiable.configuration.separator)
          find_by_public_id!(id)
        # If it's a string that looks like an encoded UUID (not a standard UUID format)
        elsif id.is_a?(String) && !id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
          uuid = decode_to_uuid(id)
          return find_by(id: uuid) if uuid
          # Fall back to regular find
          super
        else
          super
        end
      end

      # Find a record by its public ID
      def find_by_public_id(public_id)
        return nil if public_id.blank?

        prefix = get_public_id_prefix
        separator = Identifiable.configuration.separator
        return nil unless public_id.to_s.start_with?("#{prefix}#{separator}")

        encoded = public_id.to_s.sub("#{prefix}#{separator}", "")
        uuid = decode_to_uuid(encoded)
        return nil unless uuid

        find_by(id: uuid)
      end

      # Find a record by its public ID, raising RecordNotFound if not found
      def find_by_public_id!(public_id)
        find_by_public_id(public_id) || raise(ActiveRecord::RecordNotFound, "Couldn't find #{name} with public_id=#{public_id}")
      end

      # Check if a string looks like a valid public ID for this model
      def valid_public_id?(public_id)
        return false if public_id.blank?
        separator = Identifiable.configuration.separator
        public_id.to_s.start_with?("#{get_public_id_prefix}#{separator}")
      end

      # Encode a UUID to a shorter base62 string
      def encode_uuid(uuid)
        return nil if uuid.blank?

        alphabet = Identifiable.configuration.base62_alphabet

        # Remove hyphens and convert to integer
        hex = uuid.to_s.delete("-")
        num = hex.to_i(16)

        # Convert to base62
        return "0" if num.zero?

        result = ""
        while num > 0
          result = alphabet[num % 62] + result
          num /= 62
        end

        result
      end

      # Decode a base62 string back to UUID format
      def decode_to_uuid(encoded)
        return nil if encoded.blank?

        alphabet = Identifiable.configuration.base62_alphabet

        # Convert from base62 to integer
        num = 0
        encoded.each_char do |char|
          index = alphabet.index(char)
          return nil if index.nil? # Invalid character
          num = num * 62 + index
        end

        # Convert to hex and format as UUID
        hex = num.to_s(16).rjust(32, "0")
        return nil if hex.length > 32 # Overflow protection

        # Format as UUID: 8-4-4-4-12
        "#{hex[0..7]}-#{hex[8..11]}-#{hex[12..15]}-#{hex[16..19]}-#{hex[20..31]}"
      rescue StandardError
        nil
      end
    end
  end
end

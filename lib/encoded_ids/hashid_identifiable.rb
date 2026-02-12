# frozen_string_literal: true

module EncodedIds
  # HashidIdentifiable for models with integer primary keys using hashids
  #
  # Usage:
  #   class User < ApplicationRecord
  #     include EncodedIds::HashidIdentifiable
  #     set_public_id_prefix :usr
  #   end
  #
  #   user = User.first
  #   user.public_id        # => "usr_k5qx9z"
  #   User.find_by_public_id("usr_k5qx9z")  # => <User id: 1>
  #
  # Compositional prefixes:
  #   class Intel::Tool::PhoneNumber < ApplicationRecord
  #     include EncodedIds::HashidIdentifiable
  #     add_public_id_segment :int
  #     add_public_id_segment :tool
  #     add_public_id_segment :phn
  #   end
  #
  #   phone.public_id  # => "int_tool_phn_k5qx9z"
  #
  module HashidIdentifiable
    extend ActiveSupport::Concern

    included do
      include Hashid::Rails
      class_attribute :public_id_prefix
      class_attribute :public_id_segments, default: []
      class_attribute :hashid_min_length, default: 8
      class_attribute :use_prefix_in_routes, default: nil
    end

    def public_id
      "#{self.class.get_public_id_prefix}#{separator}#{hashid}"
    end

    # Override to_param for Rails URL generation
    # Respects use_prefix_in_routes configuration
    def to_param
      use_prefix = self.class.use_prefix_in_routes.nil? ?
        EncodedIds.configuration.use_prefix_in_routes :
        self.class.use_prefix_in_routes

      use_prefix ? public_id : hashid
    end

    def separator
      EncodedIds.configuration.separator
    end

    module ClassMethods
      # Simple approach: set the full prefix directly
      # Options:
      #   - min_hash_length: Minimum length of the encoded hash (default: 8)
      #   - use_prefix_in_routes: Include prefix in to_param URLs (default: nil, inherits from config)
      #   - salt: Custom salt for this model (default: nil, uses global config)
      def set_public_id_prefix(prefix, min_hash_length: 8, use_prefix_in_routes: nil, salt: nil)
        self.public_id_prefix = prefix.to_s.downcase
        self.hashid_min_length = min_hash_length
        self.use_prefix_in_routes = use_prefix_in_routes

        # Configure hashid-rails for this model with custom length and optional salt
        config_options = { min_hash_length: min_hash_length }
        config_options[:salt] = salt if salt
        hashid_config(config_options)
      end

      # Compositional approach: add segments that get joined with underscores
      def add_public_id_segment(segment)
        self.public_id_segments = public_id_segments + [segment.to_s.downcase]
      end

      # Find by public_id, hashid, or regular id
      def find(*args)
        id = args.first

        # If it's a public_id string (with prefix), find by public_id
        if id.is_a?(String) && id.include?(EncodedIds.configuration.separator)
          find_by_public_id!(id)
        # If it's a string (just the hash without prefix), try finding by hashid
        elsif id.is_a?(String)
          record = find_by_hashid(id)
          return record if record
          # Fall back to regular find in case it's actually an integer ID passed as string
          super
        else
          super
        end
      end

      def find_by_public_id(id)
        return nil unless id.is_a?(String)

        parts = id.split(EncodedIds.configuration.separator)
        hash = parts.pop  # last part is always the hash
        prefix = parts.join(EncodedIds.configuration.separator)

        return nil unless prefix == get_public_id_prefix

        find_by_hashid(hash)
      end

      def find_by_public_id!(id)
        obj = find_by_public_id(id)
        raise ActiveRecord::RecordNotFound.new(nil, name) if obj.nil?

        obj
      end

      def get_public_id_prefix
        # Segments take precedence if defined
        return public_id_segments.join(EncodedIds.configuration.separator) if public_id_segments.present?
        return public_id_prefix.to_s.downcase if public_id_prefix.present?

        raise NotImplementedError, "The #{name} model includes #{self.class.name}, but no prefix has been set. Use set_public_id_prefix or add_public_id_segment."
      end
    end
  end
end

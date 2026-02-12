# frozen_string_literal: true

module EncodedIds
  class Railtie < ::Rails::Railtie
    initializer "encoded_ids.configure_hashid_rails" do
      # Configure hashid-rails with gem settings
      Hashid::Rails.configure do |config|
        # Project-wide salt fallback chain:
        # 1. Explicitly configured via EncodedIds.configure
        # 2. Rails credentials hashid.salt
        # 3. ENV["HASHID_SALT"]
        # 4. Rails secret_key_base (not recommended for production)
        salt = EncodedIds.configuration.hashid_salt ||
               Rails.application.credentials.dig(:hashid, :salt) ||
               ENV["HASHID_SALT"] ||
               Rails.application.secret_key_base

        # Warn in development if using secret_key_base as salt
        if Rails.env.development? &&
           EncodedIds.configuration.hashid_salt.nil? &&
           Rails.application.credentials.dig(:hashid, :salt).nil? &&
           ENV["HASHID_SALT"].nil?
          Rails.logger.warn <<~WARNING
            [EncodedIds] No hashid_salt configured. Using secret_key_base as fallback.

            For better security, set a unique salt in config/credentials.yml.enc:
              hashid:
                salt: #{SecureRandom.hex(32)}

            Or via environment variable:
              HASHID_SALT=#{SecureRandom.hex(32)}

            Or in config/initializers/encoded_ids.rb:
              EncodedIds.configure do |config|
                config.hashid_salt = Rails.application.credentials.dig(:hashid, :salt) || ENV["HASHID_SALT"]
              end

            Using the default salt makes hash IDs predictable if someone knows your model IDs.
          WARNING
        end

        config.salt = salt
        config.min_hash_length = EncodedIds.configuration.hashid_min_length
        config.alphabet = EncodedIds.configuration.hashid_alphabet
      end
    end

    initializer "encoded_ids.include_controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include EncodedIds::ControllerHelpers
      end
    end
  end
end

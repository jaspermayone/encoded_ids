# frozen_string_literal: true

module EncodedIds
  class Railtie < ::Rails::Railtie
    initializer "encoded_ids.configure_hashid_rails" do
      # Configure hashid-rails with gem settings
      Hashid::Rails.configure do |config|
        config.salt = EncodedIds.configuration.hashid_salt ||
                      Rails.application.credentials.dig(:hashid, :salt) ||
                      Rails.application.secret_key_base
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

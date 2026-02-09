# frozen_string_literal: true

module Identifiable
  class Railtie < ::Rails::Railtie
    initializer "identifiable.configure_hashid_rails" do
      # Configure hashid-rails with gem settings
      Hashid::Rails.configure do |config|
        config.salt = Identifiable.configuration.hashid_salt ||
                      Rails.application.credentials.dig(:hashid, :salt) ||
                      Rails.application.secret_key_base
        config.min_hash_length = Identifiable.configuration.hashid_min_length
        config.alphabet = Identifiable.configuration.hashid_alphabet
      end
    end

    initializer "identifiable.include_controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include Identifiable::ControllerHelpers
      end
    end
  end
end

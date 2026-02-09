# frozen_string_literal: true

require "hashid/rails"
require_relative "encoded_ids/version"
require_relative "encoded_ids/configuration"
require_relative "encoded_ids/hashid_identifiable"
require_relative "encoded_ids/uuid_identifiable"
require_relative "encoded_ids/controller_helpers"
require_relative "encoded_ids/railtie" if defined?(Rails::Railtie)

module EncodedIds
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

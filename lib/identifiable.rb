# frozen_string_literal: true

require "hashid/rails"
require_relative "identifiable/version"
require_relative "identifiable/configuration"
require_relative "identifiable/hashid_identifiable"
require_relative "identifiable/uuid_identifiable"
require_relative "identifiable/controller_helpers"
require_relative "identifiable/railtie" if defined?(Rails::Railtie)

module Identifiable
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

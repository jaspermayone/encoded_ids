# frozen_string_literal: true

require "spec_helper"

RSpec.describe Identifiable do
  it "has a version number" do
    expect(Identifiable::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(Identifiable.configuration).to be_a(Identifiable::Configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      expect { |b| Identifiable.configure(&b) }.to yield_with_args(Identifiable::Configuration)
    end

    it "allows setting configuration values" do
      Identifiable.configure do |config|
        config.separator = "-"
      end

      expect(Identifiable.configuration.separator).to eq("-")

      # Reset for other tests
      Identifiable.reset_configuration!
    end
  end
end

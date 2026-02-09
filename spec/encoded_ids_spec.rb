# frozen_string_literal: true

require "spec_helper"

RSpec.describe EncodedIds do
  it "has a version number" do
    expect(EncodedIds::VERSION).not_to be nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(EncodedIds.configuration).to be_a(EncodedIds::Configuration)
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      expect { |b| EncodedIds.configure(&b) }.to yield_with_args(EncodedIds::Configuration)
    end

    it "allows setting configuration values" do
      EncodedIds.configure do |config|
        config.separator = "-"
      end

      expect(EncodedIds.configuration.separator).to eq("-")

      # Reset for other tests
      EncodedIds.reset_configuration!
    end
  end
end

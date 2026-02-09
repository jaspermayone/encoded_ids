# frozen_string_literal: true

module EncodedIds
  # Controller helpers for looking up records by either internal ID or public_id
  #
  # Automatically included in all controllers via Railtie
  #
  # Usage:
  #   # Find or return nil
  #   user = find_by_any_id(User, params[:user_id])
  #
  #   # Find or raise RecordNotFound
  #   user = find_by_any_id!(User, params[:user_id])
  #
  module ControllerHelpers
    extend ActiveSupport::Concern

    # Find a record by internal ID, public_id (with prefix), or hashid/encoded UUID (without prefix)
    def find_by_any_id(model_class, id)
      return nil if id.blank?

      # If it contains the separator, it's a full public_id with prefix
      if id.to_s.include?(EncodedIds.configuration.separator)
        model_class.find_by_public_id(id)
      else
        # Use the model's find method which handles both hashids and regular IDs
        model_class.find(id)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end

    # Find a record by either internal ID or public_id, raising if not found
    def find_by_any_id!(model_class, id)
      result = find_by_any_id(model_class, id)
      raise ActiveRecord::RecordNotFound.new(nil, model_class.name) if result.nil?

      result
    end
  end
end

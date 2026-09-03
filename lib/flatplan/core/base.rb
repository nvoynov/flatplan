# frozen_string_literal: true

require_relative 'serializable'

module Flatplan
  module Core

    # Base class providing dynamic metadata handling, automatic getter generation,
    # and serialization capability for all publication blocks.
    class Base
      include Serializable
      # @return [Hash] raw metadata configuration dictionary
      attr_reader :metadata

      # Initializes the base block and dynamically generates getters for provided metadata.
      # @param kwargs [Hash] arbitrary metadata properties
      def initialize(**kwargs)
        @metadata = kwargs
      end
    end
    
  end
end


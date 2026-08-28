# frozen_string_literal: true

module Flatplan
  module Core

    # Base class providing dynamic metadata handling, automatic getter generation,
    # and serialization capability for all publication blocks.
    class Base
      # @return [Hash] raw metadata configuration dictionary
      attr_reader :metadata

      # Initializes the base block and dynamically generates getters for provided metadata.
      # @param kwargs [Hash] arbitrary metadata properties
      def initialize(**kwargs)
        @metadata = kwargs
      end

      # Serializes the block structure into a plain Ruby Hash.
      # @return [Hash]
      def to_h
        {
          type: self.class.name.rpartition('::').last.to_sym
        }.merge(@metadata)
      end
    end
    
  end
end


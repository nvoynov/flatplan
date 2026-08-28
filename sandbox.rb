# frozen_string_literal: true

module Flatplan
  module Content
    # Base class providing dynamic metadata handling, automatic getter generation,
    # and serialization capability for all publication blocks.
    class Base
      # @return [Hash] raw metadata configuration dictionary
      attr_reader :metadata

      # Initializes the base block and dynamically generates getters for provided metadata.
      # @param kwargs [Hash] arbitrary metadata properties
      def initialize(**kwargs)
        @metadata = kwargs
        
        # Safely define getters ONLY on this specific object instance
        kwargs.each do |key, value|
          define_singleton_method(key) { value }
        end
      end

      # Serializes the block structure into a plain Ruby Hash.
      # @return [Hash]
      def to_h
        {
          type: self.class.name.split('::').last.to_sym
        }.merge(@metadata) # Fixed: used standard parentheses for merge
      end
    end
   
    # Pure container for data formatted in Pandoc Markdown.
    class Text < Base
      # @return [String] the raw text content in Pandoc Markdown format
      attr_reader :body

      # Initializes the core text content block.
      # @param body [String] the raw Markdown text
      # @param kwargs [Hash] optional layout metadata passed to base
      def initialize(body, **kwargs)
        @body = body
        super(**kwargs)
      end
    end
  end

  module Web
    # Web-specific presentation layout for text content.
    class Text < Content::Text
      # Initializes a web text presentation block with strict presentation constraints.
      # @param body [String] the raw text content in Pandoc Markdown format
      # @param alignment [Symbol] the horizontal alignment of the text (:left, :center, :right)
      # @param width_category [Symbol] the layout container width restriction (:narrow, :normal, :wide)
      def initialize(body, alignment: :left, width_category: :narrow)
        super(body, alignment: alignment, width_category: width_category)
      end
    end

    pp Text.name.rpartition(/::/)
    pp Text.name.partition(/::/)
  end
end

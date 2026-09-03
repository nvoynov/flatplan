# frozen_string_literal: true

require_relative 'base'

module Flatplan
  module Core
    
    # Shared interface for all textual content within a publication.
    # It acts as a pure container for data formatted in Pandoc Markdown,
    # leaving all semantic parsing and layout decisions to the presentation layer.
    class Text < Base
      # @return [String] the raw text content in Pandoc Markdown format
      attr_reader :body

      # Initializes the core content attributes for a text block.
      # @param body [String] the raw Markdown text
      def initialize(body, **kwargs)
        @body = body
        super()
      end
    end
  end
end


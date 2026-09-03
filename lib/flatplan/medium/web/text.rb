# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web
      # Represents a text block configured specifically for web presentation.
      # It mixes in the core {Flatplan::Content::Text} data contract and extends it
      # with layout and alignment properties required by web renderers.
      class Text < Flatplan::Core::Text

        # @return [Symbol] the text alignment directive (:left, :center, :right)
        attr_reader :alignment

        # @return [Symbol] the container width category (:narrow, :normal, :wide)
        attr_reader :width_category

        # Initializes a web text presentation block.
        # @param body [String] the raw text content in Pandoc Markdown format
        # @param alignment [Symbol] the horizontal alignment of the text
        # @param width_category [Symbol] the structural width restriction for the layout container
        def initialize(body, alignment: :left, width_category: :narrow)
          super(body)        
          @alignment = alignment
          @width_category = width_category
        end
      end
    end
  end
end


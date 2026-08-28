# frozen_string_literal: true

require_relative 'base'

module Flatplan
  module Core
    # Shared interface for any multi-element narrative or publication.
    # It encapsulates both the core document metadata (author, title, etc.)
    # and the ordered sequence of content blocks that form the visual story.
    class Story < Base
      # @return [String] the title of the story
      attr_reader :title

      # @return [String] the author or creator of the publication
      attr_reader :author

      # @return [String, nil] a short summary or description of the narrative
      attr_reader :description

      # @return [Object, nil] the creation or publication date (typically Date or Time)
      attr_reader :date

      # @return [Array<Object>] the ordered collection of narrative blocks
      attr_reader :elements

      # Initializes the story with its metadata and initial blocks.
      # @param title [String] the title of the story
      # @param author [String] the name of the author
      # @param description [String, nil] a short intro or description
      # @param date [Object, nil] the publication date
      # @param elements [Array<Object>] initial content blocks
      def initialize(title, author:, description: nil, date: nil, elements: [], **kwargs)
        @title       = title
        @author      = author
        @description = description
        @date        = date
        @elements    = elements
        super(**kwargs)
      end

      # Appends a new content block to the end of the story.
      # @param element [Object] any content element (e.g., Text, Media, VisualPause)
      # @return [Array<Object>] the updated collection of elements
      def append(element)
        @elements << element
      end
    end
  end
end

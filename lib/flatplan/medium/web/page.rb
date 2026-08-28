# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Web

      # Represents a concrete web page publication.
      # It mixes in the core {Flatplan::Content::Story} behavior and metadata,
      # extending it with routing configuration specific to the web medium.
      class Page < Flatplan::Core::Story
        # @return [String] the URL-friendly identifier (slug) for routing
        attr_reader :slug

        # Initializes a web page publication.
        # @param title [String] the title of the story
        # @param author [String] the name of the author
        # @param slug [String, nil] the unique URL slug (auto-generated from title if nil)
        # @param description [String, nil] a short intro or description
        # @param date [Object, nil] the publication date
        # @param elements [Array<Object>] initial content blocks for the web view
        def initialize(title, author:, slug: nil, description: nil, date: nil, elements: [])
          super(title, author:, description:, date:, elements:)
          @slug = slug || generate_slug(title)
        end

        private

        # Generates a basic URL-friendly slug from the given title string.
        # @param string [String] the source title
        # @return [String] formatted slug
        def generate_slug(string)
          string.to_s
                .downcase
                .gsub(/[^a-z0-9\s-]/, '') # Remove special characters
                .strip
                .gsub(/\s+/, '-')         # Replace spaces with hyphens
                .gsub(/-+/, '-')          # Remove duplicate hyphens
        end
      end
    end
  end
end


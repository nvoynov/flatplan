require_relative "base"

module Flatplan
  module Model

    # The Aggregate Root representing a complete photographic publication series.
    # It acts as the core orchestrator for text segments and visual chapters.
    class SeriesPublication < Base
      # @return [String] the primary title of the photo series
      attr_accessor :title

      # @return [String, nil] the author name or gallery owner
      attr_accessor :author

      # @return [String, nil] creation date or time range of the series
      attr_accessor :date

      # @return [String, nil] geographical or historical location name
      attr_accessor :location

      # @return [Array<String>] collection of SEO keywords and tags
      attr_accessor :keywords

      # @return [String, nil] summary or curatorial description of the series
      attr_accessor :description

      # @return [Array<LayoutSection>] ordered list of editorial layout spreads
      attr_accessor :sections

      # Initializes a structured series publication model instance.
      # Ensure all attributes are explicit constructor keyword arguments to 
      # satisfy reflective and immutable copying via the underlying Base#with.
      #
      # @param title [String] the editorial series title
      # @param author [String, nil] series gallery owner
      # @param date [String, nil] capture timeline or production years
      # @param location [String, nil] place descriptor metadata
      # @param keywords [Array<String>] collection of metadata search tags
      # @param description [String, nil] contextual series overview summary
      # @param sections [Array<LayoutSection>] initial layouts list tracking
      def initialize(
        title:, 
        author: nil, 
        date: nil, 
        location: nil, 
        keywords: [], 
        description: nil,
        sections: []
      )
        super()
        @title = title
        @author = author
        @date = date
        @location = location
        @keywords = keywords
        @description = description
        @sections = sections
      end

      # Appends a newly created layout section to the publication pipeline.
      #
      # @param section [LayoutSection] the section instance to append
      # @return [Array<LayoutSection>] updated array of sequential sections
      def add_section(section)
        @sections << section
      end
    end
  end
end

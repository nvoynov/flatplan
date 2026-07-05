require_relative 'base'

module Flatplan
  module Model

    # The Aggregate Root representing a complete photographic publication series.
    # It acts as the orchestrator for text segments and visual chapters.
    class SeriesPublication < Base
      # @return [String] the primary title of the photo series
      attr_accessor :title

      # @return [String, nil] the author name or gallery owner
      attr_accessor :author

      # @return [String, nil] creation date or time range of the series
      attr_accessor :date

      # @return [String, nil] summary or metadata description
      attr_accessor :description

      # @return [Array<LayoutSection>] ordered list of editorial layout spreads
      attr_accessor :sections

      # Initializes an empty standalone series publication.
      #
      # @param title [String] the editorial series title
      # @param author [String, nil] series gallery owner
      # @param date [String, nil] capture timeline
      # @param description [String, nil] context metadata description
      # @param sections: [Array<LayoutSection>, nil] context metadata description
      def initialize(title:, author: nil, date: nil, description: nil, sections: nil)
        @title = title
        @author = author
        @date = date
        @description = description
        @sections = sections || []
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

# frozen_string_literal: true

require_relative 'media'

module Flatplan
  module Core
    
    # Shared interface for an ordered collection of media assets.
    # It acts as a semantic container for multiple images or videos,
    # preserving their chronological or narrative order for the presentation layer.
    class MediaAssets < Base
      # @return [Array<Media>]
      attr_reader :assets

      # Initializes the container with an ordered array of media assets.
      # @param assets [Array<Media>]
      def initialize(assets, **kwargs)
        @assets = assets
        super(**kwargs)
      end
    end
  end
end


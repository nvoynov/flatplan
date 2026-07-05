require_relative 'base'

module Flatplan
  module Model

    # Abstract base class representing a generic editorial block or layout spread.
    # It acts as a domain entity holding visual assets.
    class LayoutSection < Base
      # @return [Array<LayoutAsset>] list of photos assigned to this section
      attr_accessor :media_assets

      # Initializes a basic layout section.
      #
      # @param media_assets [Array<LayoutAsset>] collection of assets
      def initialize(media_assets: [])
        @media_assets = media_assets
      end
    end
  end
end

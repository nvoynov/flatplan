# frozen_string_literal: true

require_relative '../../core'

module Flatplan
  module Medium
    module Book
      # Represents a collection of media assets arranged in a layout grid for the web.
      # It mixes in the core {Flatplan::Content::MediaAssets} structure and defines
      # grid properties like columns count and aspect ratio constraints.
      class MediaAssets < Flatplan::Core::MediaAssets

        # @return [String] 
        attr_reader :print_template

        # Initializes a web media grid collection.
        # @param assets [Array<Object>] collection of elements implementing {Flatplan::Content::Media}
        # @param print_layout [String]
        def initialize(assets, print_template: nil)
          super(assets)
          @print_template = print_template
        end
      end
    end
  end
end


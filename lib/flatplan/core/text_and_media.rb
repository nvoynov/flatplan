# frozen_string_literal: true

require 'forwardable'
require_relative 'text'
require_relative 'media_assets'

module Flatplan
  module Core
    
    # A concrete semantic layout that tightly binds a single text narrative 
    # with a collection of media assets.
    # It guarantees that these two distinct content forms remain associated
    # regardless of the presentation layer.
    class TextAndMedia < Base
      extend Forwardable
      def_delegator :@media_assets, :assets

      # @return [Text]
      attr_reader :text

      # @return [MediaAssets}
      attr_reader :media_assets

      # Initializes the text-and-media content block.
      # @param text [Text]
      # @param media [MediaAssets]
      def initialize(text, media_assets, **kwargs)
        @text  = text
        @media_assets = media_assets
        super(**kwargs)
      end
    end
  end
end


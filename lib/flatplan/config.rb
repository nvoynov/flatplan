# lib/flatplan/config.rb

require "singleton"
require "forwardable"

module Flatplan
  # Holds raw configuration values for the Flatplan engine.
  class ConfigData
    # @return [Array<String>] list of supported image extensions
    attr_reader :image_extensions

    # @return [String] the target naming convention for manifest files
    attr_reader :series_manifest_name

    def initialize
      @image_extensions = %w[.webp .jpg .jpeg .png .tif .tiff]
      @series_manifest_name = 'SERIES.md'
    end
  end

  # Singleton configuration registry acting as a proxy to underlying settings.
  class Config
    include Singleton
    extend Forwardable

    # Delegate setup readers directly to the immutable ConfigData instance
    def_delegators :@data, :image_extensions, :series_manifest_name

    def initialize
      @data = ConfigData.new
    end
  end
end

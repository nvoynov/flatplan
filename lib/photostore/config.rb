# lib/photostore/config.rb

require "yaml"
require "singleton"

module PhotoStore
  # Manages configuration loading and accessors for the PhotoStore registry.
  class Config
    include Singleton

    # @return [String] root path to master images directory
    attr_reader :masters_dir

    # @return [Array<String>] list of file extensions to scan
    attr_reader :supported_extensions

    def initialize
      config_path = File.expand_path("../../config/photostore.yml", __dir__)
      raw_config = YAML.load_file(config_path) if File.exist?(config_path)
      raw_config ||= {}

      @masters_dir = raw_config["masters_dir"] || "gallery/masters"
      @supported_extensions = raw_config["supported_extensions"] || [".tif", ".tiff"]
    end
  end
end

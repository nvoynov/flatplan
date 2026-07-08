require "yaml"
require "singleton"
require "forwardable"

module Flatplan
  # An immutable configuration structure tracking global image masks,
  # custom manifest naming conventions, and default publication author tags.
  ConfigData = Data.define(
    :image_extensions,     # [Array<String>] list of supported image extensions
    :series_manifest_name, # [String] naming convention for series manifest files
    :author,               # [String, nil] default fallback author name for metadata
    :default_keywords      # [Array<String>] default fallback tags for SEO front matter
  )

  # Centralized configuration registry acting as a stable, lazy-loading proxy
  # that manages flatplan.yml files disk lifecycle footprints at boot time.
  class Config
    include Singleton
    extend Forwardable

    FILE_NAME          = "flatplan.yml"
    MANIFEST_NAME      = 'SERIES.md'
    DEFAULT_EXTENSIONS = %w[.webp .jpg .jpeg .png .tif .tiff]
    DEFAULT_KEYWORDS   = %W[fine-art photography documentary]
    DEFAULT_AUTHOR     = 'Unknown Author'
        
    # Delegate setup readers directly to the immutable internal ConfigData instance
    def_delegators :@data, :image_extensions, :series_manifest_name, 
                           :author, :default_keywords

    def initialize
      @data = load_or_create
    end

    private

    # Loads the configuration from disk or creates a default flatplan.yml file.
    # @return [ConfigData] the frozen settings data container
    def load_or_create
      local_path = File.join(Dir.pwd, FILE_NAME)

      if File.exist?(local_path)
        parsed = YAML.load_file(local_path) || {}
        
        ConfigData.new(
          image_extensions: parsed["image_extensions"] || DEFAULT_EXTENSIONS,
          series_manifest_name: parsed["series_manifest_name"] || MANIFEST_NAME,
          author: parsed["author"] || DEFAULT_AUTHOR,
          default_keywords: parsed["default_keywords"] || DEFAULT_KEYWORDS
        )
      else
        # Fallback to pristine defaults and persist them natively to disk
        default_data = ConfigData.new(
          image_extensions: DEFAULT_EXTENSIONS,
          series_manifest_name: MANIFEST_NAME,
          author: DEFAULT_AUTHOR,
          default_keywords: DEFAULT_KEYWORDS
        )

        write_default_file(local_path, default_data)
        default_data
      end
    end

    # Serializes the default configuration metrics back onto a flat YAML file.
    def write_default_file(path, data)
      payload = data.to_h.transform_keys(&:to_s)
      File.write(path, YAML.dump(payload))
    end

  end
end

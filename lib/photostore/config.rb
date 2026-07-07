# lib/photostore/config.rb

require "yaml"
require "singleton"
require "forwardable"

module PhotoStore

  # Manages configuration parameters for the PhotoStore registry.
  class ConfigData
    # @return [String] root path to master images directory
    attr_reader :masters_dir

    # @return [Array<String>] list of file extensions to scan
    attr_reader :supported_extensions

    # @return [String] datastore file
    attr_reader :datastore

    def initialize
      config_path = File.expand_path("../../#{CONFIG_FILE}", __dir__)
      unless File.exist?(config_path)        
        File.write(config_path, YAML.dump(CONFIG_STARTER))
        puts <<~TEXT
          Created default configuration #{CONFIG_FILE}
          Provide real path to your gallery masters and run again.
        TEXT
        exit
      end
      raw_config = YAML.load_file(config_path) if File.exist?(config_path)
      raw_config ||= {}

      @masters_dir = raw_config["masters_dir"] || GALLERY_MASTERS
      @supported_extensions = raw_config["supported_extensions"] || IMAGE_EXTENTIONS
      @datastore =
        File.join('..', '..',
          raw_config["datastore_path"],
          raw_config["datastore"]
        ).then{
          File.expand_path(it, __dir__)
        }
    end

    CONFIG_FILE = 'photostore.yml'
    DATASTORE_PATH = 'data'
    DATASTORE = 'photostore.json'
    GALLERY_MASTERS = 'gallery/masters'
    IMAGE_EXTENTIONS = %W[.tif .tiff .jpg .jpeg] 
    CONFIG_STARTER = {
      'masters_dir' => GALLERY_MASTERS,
      'supproted_extentions' => IMAGE_EXTENTIONS,
      'datastore_path' => DATASTORE_PATH,
      'datastore' => DATASTORE
    }
  end
  
  # Manages configuration for the PhotoStore registry.
  class Config
    include Singleton
    extend Forwardable

    def_delegators :@config, :masters_dir, :supported_extensions, :datastore

    def initialize
      @config = ConfigData.new
    end
  end
end

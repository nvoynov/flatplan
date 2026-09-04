require "yaml"
require "singleton"
require "forwardable"
require "fileutils"

module Basic

  # Abstract base class that automates lazy loading, default file generation,
  # configuration proxy forwarding, and fail-safe recovery for standard 
  # Ruby Data value objects.
  class Configuration
    class << self
      # Establishes the target Data class schema, automatically injecting
      # Singleton mechanics and forwarding proxy accessors onto the child class.
      #
      # @param data_class [Class] the standard Ruby Data class template
      # @param file_name [String, nil] custom file override or default deduced
      def manage(data_class, config_file: nil)
        # Deduce file name from class name if not explicitly specified
        # e.g., PhotoStore::Config -> "photostore.yml"
        @config_file = config_file || "#{name.split("::").first.downcase}.yml"
        @data_class = data_class

        # Setup standard pattern inclusions inside the active subclass context
        include Singleton
        extend Forwardable

        # Dynamically extract all structural parameter members from the Data class
        # and configure direct method forwarders to the internal @data state
        data_class.members.each do |member|
          def_delegator :@data, member
        end
      end

      attr_reader :config_file, :data_class
    end

    # Explicit baseline initializer hook executed natively by Singleton.instance
    def initialize
      @data = load_or_create
    end

    private

    def config_file = self.class.config_file

    # @return [String] fullpath to configuration file
    def find_config_file
      local_config = File.join(Dir.pwd, config_file)
      return local_config if File.exist?(local_config)

      File.join(XDGSpec.config_dir, config_file)
        .tap{ FileUtils.mkdir_p(XDGSpec.config_dir) }
    end
    
    # Evaluates disk presence, parses YAML metrics, or triggers fail-safe recovery.
    # @return [Object] frozen state token instance of the declared Data class
    def load_or_create
      target_class = self.class.data_class
      pristine_default = target_class.new

      file_path = find_config_file 
      if File.exist?(file_path)
        begin
          parsed = YAML.load_file(file_path) || {}
          symbolized = parsed.transform_keys(&:to_sym)
          valid_args = symbolized.slice(*target_class.members)
          target_class.new(**pristine_default.to_h.merge(valid_args))
        rescue StandardError
          # Fail-Safe: Fallback onto defaults smoothly upon any file corruption
          pristine_default
        end
      else
        payload = pristine_default.to_h.transform_keys(&:to_s)
        File.write(file_path, YAML.dump(payload))
        puts "Configuration created #{file_path}"
        puts "Configure then repeat the request"
        exit
      end
    end
  end
end


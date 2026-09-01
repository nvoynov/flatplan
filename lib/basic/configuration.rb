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
      def manage(data_class, target_file: nil)
        # Deduce file name from class name if not explicitly specified
        # e.g., PhotoStore::Config -> "photostore.yml"
        @target_file = target_file || "#{name.split("::").first.downcase}.yml"
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

      # Expose read accessors for the private class-level configuration state
      attr_reader :target_file, :data_class
    end

    # Explicit baseline initializer hook executed natively by Singleton.instance
    def initialize
      @data = load_or_create
    end

    def cache_dir
      @cache_dir ||= 
        # File.join(XDGSpec.cache_dir, File.basename(target_file, '.*'))
        File.join(stories_dir, '.cache')
          .tap{ FileUtils.mkdir_p it }
    end
    
    private

    def target_file = self.class.target_file

    # Climbs up the directory tree starting from the current directory (Dir.pwd)
    # until it finds a .flatplan.yml file or hits the root/home boundary.
    # @return [String, nil] fullpath to configuration file on nil
    def find_hierarchical_config
      current = Pathname.new(Dir.pwd)
      home    = Pathname.new(Dir.home)

      # Climb up the tree
      loop do
        config_path = current.join(target_file)
        return config_path if config_path.exist?

        # Stop if we reached the root directory or crossed the home directory path
        break if current.root? || current == home

        current = current.parent
      end
      
      home.join(target_file)
    end
    
    # Evaluates disk presence, parses YAML metrics, or triggers fail-safe recovery.
    # @return [Object] frozen state token instance of the declared Data class
    def load_or_create
      target_class = self.class.data_class

      # 1. Instantiate the absolute pristine default instance state safely
      # by invoking the Data constructor with zero keywords arguments
      pristine_default = target_class.new

      file_path = find_hierarchical_config 
      if File.exist?(file_path)
        begin
          parsed = YAML.load_file(file_path) || {}
          
          # Convert keys to symbols to satisfy strict Data constructor requirements
          symbolized = parsed.transform_keys(&:to_sym)

          # Extract only keys that actually exist in the declared Data schema members
          valid_args = symbolized.slice(*target_class.members)

          # Build combined configuration merging disk metrics onto defaults
          target_class.new(**pristine_default.to_h.merge(valid_args))
        rescue StandardError
          # Fail-Safe: Fallback onto defaults smoothly upon any file corruption
          pristine_default
        end
      else
        # 2. Persist default configuration matrix directly back onto the root path
        payload = pristine_default.to_h.transform_keys(&:to_s)
        File.write(file_path, YAML.dump(payload))
        # pristine_default
        puts "Created default configuraton #{file_path}"
        puts "Configure first then repeat the task"
        exit
      end
    end
  end
end


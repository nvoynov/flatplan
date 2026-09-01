require_relative "../basic"

module CLI
  
  # Initialize story manifest command
  class Init < ::Basic::CliCommand
    shortcut :i
    summary "Initialize a new series workspace folder and enriched manifest"

    # Triggers option parsing and physical folder orchestration.
    def call(argv)
      if argv.empty?
        puts "Error: New series workspace directory name missing."
        puts
        puts build_parser({})
        exit 1
      end

      options = { keywords: [], manifiest: nil }
      parser = build_parser(options)
      parse_options!(argv, parser)
      pp options
      execute(argv.first, options[:keywords], manifest: options[:manifest])
    end
    
    # Public interface hook implementing the baseline parser lookup
    def parser
      build_parser({})
    end

    private

    def build_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: flatplan #{self.class.command_name} <directory> [options]"
        opts.separator ""
        opts.separator "Options:"
        
        opts.on('-m', '--manifest', String, 'Story manifest name') do |val|
          options[:manifest] = val
        end
        
        opts.on("-k", "--keywords K1,K2,K3", Array, 
                "Comma-separated list of keywords") do |list|
          options[:keywords] = list.map(&:strip)
        end

        opts.on("-h", "--help", "Show help documentation for this subcommand") do
          puts opts
          exit
        end
      end
    end
    
    # #define EX_USAGE	  64	/* command line usage error */
    # #define EX_DATAERR	65	/* data format error */
    # #define EX_NOINPUT	66	/* cannot open input */
    # #define EX_NOPERM	  77	/* permission denied */

    def execute(directory, custom_keywords, manifest: nil)
      config = Config.instance

      assets_dir = directory if Dir.exist?(directory)
      assets_dir ||= File.expand_path(directory, config.assets_dir)
      unless Dir.exist?(assets_dir)
        warn "#{$0}: ! Cannot open '#{directory}' does not exist"
        exit 66
      end
      
      active_keywords = custom_keywords.empty? ? config.keywords : custom_keywords
      warn "#{$0}:  > Generating flatplan manifest"
      story_manifest = InitCommand.web.call(assets_dir, active_keywords, manifest_name: manifest)
      warn "#{$0}:  > Manifest successfully initialized. Ready for curation."
      puts story_manifest
    end
  end
end

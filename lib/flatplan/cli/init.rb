# lib/flatplan/cli/init.rb

require_relative "../../basic/cli_command"
require_relative "../service"
require_relative "../config"

module Flatplan
  module CLI
    # Dedicated Command Object handling workspace directory setup 
    # and initial publishing manifest seeding.
    class Init < ::Basic::CliCommand
      # One clean declarative macro configures your short command triggers!
      shortcut :i
      summary "Initialize a new series workspace folder and enriched manifest"

      # Triggers option parsing and physical folder orchestration.
      def call(argv)
        # 1. Fail-Fast: Immediately validate positional parameters at the front gate
        if argv.empty?
          puts "Error: New series workspace directory name missing."
          puts
          puts build_parser({})
          exit 1
        end

        options = { keywords: [] }
        parser = build_parser(options)

        # 2. Seamlessly execute option parsing via the inherited base class tracker
        parse_options!(argv, parser)

        # 3. Post-parsing: execution of the business logic payload
        execute(argv.first, options[:keywords])
      end
      
      # Public interface hook implementing the baseline parser lookup
      def parser
        build_parser({})
      end

      private

      # Factory method isolating OptionParser schema construction using native Ruby 3.4 DSL.
      def build_parser(options)
        OptionParser.new do |opts|
          opts.banner = "Usage: flatplan #{self.class.command_name} <name> [options]"
          
          opts.separator ""
          opts.separator "Options:"
          
          opts.on("-k", "--keywords K1,K2,K3", Array, 
                  "Comma-separated list of keywords for Kairos hints") do |list|
            options[:keywords] = list.map(&:strip)
          end

          opts.on("-h", "--help", "Show help documentation for this subcommand") do
            puts opts
            exit
          end
        end
      end

      def execute(series_name, custom_keywords)
        config = Config.instance
        target_dir = File.expand_path(series_name, config.series_dir)
        
        unless Dir.exist?(target_dir)
          puts "==> Creating new series workspace: #{target_dir}"
          FileUtils.mkdir_p(target_dir)
        end

        active_keywords = custom_keywords.empty? ? config.default_keywords : custom_keywords
        puts "==> Generating enriched publishing manifest target: #{config.series_manifest_name}"
        
        Service::CreateInitialManifest.call(
          directory_path: target_dir,
          keywords: active_keywords
        )
        puts "==> Series '#{series_name}' successfully initialized. Ready for curation."
      end
    end
  end
end

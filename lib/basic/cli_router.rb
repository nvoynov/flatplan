# lib/basic/cli_router.rb

module Basic
  # Abstract framework routing core that automates subcommands scanning
  # within its namespace scope, handles help manual generation, 
  # and dispatches dynamic polymorphic execution pipelines.
  class CliRouter
    class << self
      # Abstract stub intended to be overridden in the main project CLI root.
      # @return [String] the primary ASCII art title banner string
      def banner
        "==> CLI Utility Framework"
      end

      # Dynamically discovers and caches all classes within the router's
      # module namespace that inherit from Basic::CliCommand.
      #
      # @return [Array<Class>] collection of active subcommand classes
      def subcommands
        @subcommands ||= begin
          # Get the parent module namespace (e.g., Flatplan::CLI -> Flatplan)
          parent_mod = Object.const_get(name.split("::")[0..-2].join("::"))
          
          # Scan all constants inside the module to find CliCommand subclasses
          parent_mod.constants.map { |c| parent_mod.const_get(c) }.select do |klass|
            klass.is_a?(Class) && klass < ::Basic::CliCommand
          end
        end
      end

      # Main framework execution entry point parsing subcommands.
      #
      # @param argv [Array<String>] raw system command line arguments stream
      def call(argv = ARGV)
        if argv.empty?
          print_main_usage
          exit
        end

        token = argv.shift

        # 1. Framework Routing: Contextual Help Manual Lookup
        if token == "help"
          process_help_subcommand!(argv)
          exit
        end

        if %w[-h --help].include?(token)
          print_main_usage
          exit
        end

        # 2. Dynamic Polymorphic Dispatch Sequence
        active_command = subcommands.find { |cmd| cmd.match?(token) }

        if active_command
          # Pure, abstract, and uniform interface call tracking
          active_command.call(argv)
        else
          # 3. Fallback Branch: Route straight to default execution if unmatched
          fallback_command(token, argv)
        end
      end

      private

      # Default execution interceptor customized by downstream routers.
      def fallback_command(token, argv)
        argv.unshift(token)
        preview_cmd = subcommands.find { |cmd| cmd.command_name == "preview" }
        
        if preview_cmd
          preview_cmd.call(argv)
        else
          puts "Error: Unrecognized command token input: '#{token}'\n\n"
          print_main_usage
          exit 1
        end
      end

      # Extracts and prints granular help information using pure public OOP interfaces.
      def process_help_subcommand!(argv)
        target_token = argv.shift

        if target_token
          matched = subcommands.find { |cmd| cmd.match?(target_token) }
          if matched
            # 100% Stable, Clean, and Public Contract Call
            puts matched.new.parser
            return
          end
        end

        print_main_usage
      end

      # Compiles and formats a unified, responsive general application usage layout.
      def print_main_usage
        puts banner
        puts "Usage: #{command_name} <command> [options]"
        puts
        puts "Commands:"

        subcommands.each do |cmd|
          aliases_hint = cmd.aliases.empty? ? "" : "#{cmd.aliases.join(', ')}, "
          name_str = "#{aliases_hint}#{cmd.command_name}".ljust(12)
          puts "  #{name_str} #{cmd.summary}"
        end

        puts "  help         Show help documentation for a specific subcommand"
        puts
        puts "General options:"
        puts "  -h, --help   Show application help usage information"
      end

      def command_name
        name.split("::").first.downcase
      end
    end
  end
end

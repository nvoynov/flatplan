# lib/basic/cli_command.rb

require "optparse"
require_relative "callable"

module Basic
  # Abstract infrastructure base class providing unified option parsing,
  # fail-fast validations, and declarative triggers with summary descriptions.
  class CliCommand
    extend Callable

    class << self
      # Declaratively registers short console triggers for the command subclass.
      #
      # @param tokens [Array<String, Symbol>] shortcut tokens array list
      def shortcut(*tokens)
        @command_shortcuts = tokens.map { |t| t.to_s.strip.downcase }
      end

      # @return [Array<String>] collection of registered command alias triggers
      def aliases
        @command_shortcuts || []
      end

      # Declaratively registers a concise curatorial text summary sentence 
      # for the main general framework help menu layout display.
      #
      # @param text [String] brief description of the command's purpose
      def summary(text = nil)
        @command_summary = text.to_s.strip if text
        @command_summary || "Execute #{command_name} operations"
      end

      # Automatically deduces the canonical command name from the class scope.
      # @return [String] primary command identifier (e.g. "init")
      def command_name
        name.split("::").last.downcase
      end

      # Verifies if the incoming terminal token matches the name or any shortcut.
      def match?(token)
        input = token.to_s.strip.downcase
        input == command_name || aliases.include?(input)
      end
    end

    # Public unified interface for external help document extractions.
    # Must be overridden by child classes to return their specific OptionParser.
    #
    # @return [OptionParser] pre-configured option parser instance
    def parser
      raise NotImplementedError, "Subclasses must implement #parser interface"
    end

    protected

    # Safely executes the OptionParser execution loop against a given parser instance.
    def parse_options!(argv, parser)
      begin
        parser.parse!(argv)
      rescue OptionParser::ParseError => e
        puts "Error: #{e.message}"
        puts
        puts parser
        exit 1
      end
      argv
    end
  end
end

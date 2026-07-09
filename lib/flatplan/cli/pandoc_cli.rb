require_relative "../../basic"

module Flatplan
  module CLI

    # Internal infrastructure tool wrapping the system Pandoc compiler securely
    class PandocCli < ::Basic::CliTool
      executable :pandoc
      
      # Compiles Markdown to a clean, standard HTML5 document linked to a local stylesheet.
      def compile(source:, stylesheet:, destination:, workspace:)
        execute_command(
          source,
          "-f", "markdown+fenced_divs",
          "-t", "html5",
          "-s",
          "-c", stylesheet,
          "-o", destination,
          chdir: workspace 
        )
      end
    end
  end
end

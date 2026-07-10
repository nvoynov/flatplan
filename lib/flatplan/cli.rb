# lib/flatplan/cli.rb

require_relative "../basic/cli_router"
require_relative "banner"
require_relative "cli/init"
require_relative "cli/preview"

module Flatplan
  module CLI
    extend self
    
    # Application orchestration layer responsible for dynamically 
    # registering, routing, and dispatching command execution pipelines.
    class Router < ::Basic::CliRouter
      # Overriding the abstract framework banner string method with our native layout
      def self.banner = BANNER
    end

    def call
      Router.call
    end
  end
end

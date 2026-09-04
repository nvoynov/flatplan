require_relative 'basic'
require_relative 'cli/init'
require_relative 'cli/preview'

# Command line interface
module CLI
  extend self

  BANNER = <<~TEXT
    \e[36m |¯ |   /\\ ¯|¯ |¯\\ |   /\\  |\\| \e[0m
    \e[36m |- |_ /--\\ |  |¯  |_ /--\\ | | \e[0m
    storage: #{Config.instance.stories_dir}
    version: #{VERSION}

  TEXT

  # CLI Router
  class Router < ::Basic::CliRouter
    # Overriding the abstract framework banner string method with our native layout
    def self.banner = BANNER
  end

  def call
    Router.call
  end
end 

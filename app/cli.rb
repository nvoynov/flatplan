require_relative 'basic'
require_relative "cli/init"

# Command line inteface
module CLI
  extend self

  # BANNER = <<~TEXT
  #   \e[36m |\\| |¯  /¯\\  /\\  ¯|¯ | \\ / |¯  (¯ \e[0m
  #   \e[36m | | |__ \\_] /--\\  |  |  V  |__ __) \e[0m
  #    manifests: #{Config.instance.stories_dir}
  #    version: #{VERSION}
    
  # TEXT

  BANNER = <<~TEXT
    \e[36m |¯ |   /\\ ¯|¯ |¯\\ |   /\\  |\\| \e[0m
    \e[36m |- |_ /--\\ |  |¯/ |_ /--\\ | | \e[0m
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

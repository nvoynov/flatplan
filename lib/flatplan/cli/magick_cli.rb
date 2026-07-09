require_relative "../../basic"

module Flatplan
  module CLI

    # Internal infrastructure tool executing fast ImageMagick conversions
    class MagickCli < ::Basic::CliTool
      executable :magick
      
      # High-speed downscaling optimized for quick browser previews
      def convert_to_thumbnail(source:, destination:)
        cmd = [source, "-resize", "600x400>", "-quality", "75", destination]
        execute_command(*cmd)
      end
    end
    
  end
end

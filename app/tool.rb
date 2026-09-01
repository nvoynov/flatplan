# frozen_string_literal: true

require_relative 'tool/pandoc'
require_relative 'tool/magick'

# Toolbox namespace
module Tool
end

MagickTool = Tool::Magick
PandocTool = Tool::Pandoc

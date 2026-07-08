# 
# "Negatives" Acts as the digital darkroom foundation by scanning master image
#   folders and extracting their technical DNA (EXIF timestamps, dimensions,
#   and other metadata). It catalogs raw, unedited photographic assets, preparing
#   them for downstream context generation and web presentation pipelines.
# 

require_relative 'negatives/basic'
require_relative 'negatives/image'
require_relative 'negatives/configuration'
require_relative 'negatives/config'
require_relative 'negatives/scanner'
require_relative 'negatives/builder'
require_relative 'negatives/store'
require_relative 'negatives/cli'

# Root Negatives namespace
module Negatives
end

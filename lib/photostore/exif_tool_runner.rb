require 'json'
require_relative 'basic'

module PhotoStore
  
  # Independent system utility execution runner that leverages ExifTool
  # to query image hardware specs, capture timestamps, and creative metadata.
  class ExifToolRunner < ::Basic::CliTool
    extend ::Basic::Callable

    def initialize
      # Verify if the target binary is installed and executable in the system
      unless system("command -v exiftool >/dev/null 2>&1")
        raise RuntimeError, "ExifTool CLI dependency is missing in this OS!"
      end
    end

    # Extracts metadata and compiles it into a temporary hash structure.
    #
    # @return [Hash] extracted metadata registry
    def call
      config = Config.instance

      # 1. Build explicit extension filtering flags for ExifTool CLI (e.g. -ext tif -ext tiff)
      ext_flags = config.supported_extensions.flat_map do |ext|
        ["-ext", ext.sub(".", "")]
      end

      # 2. Invoke the external tool once for the whole directory tree natively
      # We ask ExifTool to output JSON (-j) and do a recursive folder scan (-r)
      raw_json = execute_command(
        "exiftool", "-j", "-r",
        "-ImageWidth", "-ImageHeight", "-DateTimeOriginal",
        "-ObjectName", "-Caption-Abstract", "-Model", "-LensModel",
        *ext_flags,
        config.masters_dir
      )

      JSON.parse(raw_json).map do |parsed|
        {
          filename: parsed["SourceFile"],
          width: parsed["ImageWidth"]&.to_i,
          height: parsed["ImageHeight"]&.to_i,
          captured_at: parsed["DateTimeOriginal"],
          title: parsed["ObjectName"] || parsed["Title"],
          description: parsed["Caption-Abstract"] || parsed["Description"],
          camera: parsed["Model"],
          lens: parsed["LensModel"] || parsed["Lens"]
        }
      end
      
    end
  end
end

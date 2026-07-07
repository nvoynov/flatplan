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
    # @param file_path [String] path to the physical image master file
    # @return [Hash] extracted metadata registry with extended attributes
    def call(file_path)
      # Request extended parameters from ExifTool binary execution pipeline
      raw_json = execute_command(
        "exiftool", "-j", 
        "-ImageWidth", "-ImageHeight", "-DateTimeOriginal",
        "-ObjectName", "-Caption-Abstract", "-Model", "-LensModel",
        file_path
      )
      
      parsed = JSON.parse(raw_json).first
      unless parsed
        raise "ExifTool failed to parse file at #{file_path}"
      end

      filename = File.basename(file_path)

      # Temporary return structure until the domain Model layer is refactored
      {
        filename: filename,
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

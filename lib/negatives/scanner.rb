require 'json'
require 'time'
require_relative 'config'

module Negatives
  
  # Independent system utility execution runner that leverages ExifTool
  # to query image hardware specs, capture timestamps, and creative metadata.
  class Scanner < ::Basic::CliTool
    executable :exiftool
    
    # Extracts metadata and compiles it into a temporary hash structure.
    #
    # @return [Hash] extracted metadata registry
    def call
      config = Config.instance

      # 1. Build explicit extension filtering flags for ExifTool CLI (e.g. -ext tif -ext tiff)
      ext_flags = config.image_extensions.flat_map do |ext|
        ["-ext", ext.sub(".", "")]
      end

      # 2. Invoke the external tool once for the whole directory tree natively
      # We ask ExifTool to output JSON (-j) and do a recursive folder scan (-r)
      raw_json = execute_command(
        "-j", "-r",
        "-ImageWidth", "-ImageHeight", "-DateTimeOriginal",
        "-ObjectName", "-Caption-Abstract", "-Model", "-LensModel",
        *ext_flags,
        config.negatives_dir
      )

      JSON.parse(raw_json).map do |parsed|
        filename = parsed["SourceFile"]
        original = parsed['DateTimeOriginal']
        captured_at = original ? exif_time(original) : File.mtime(filename)  
        {
          filename: filename,
          width: parsed["ImageWidth"]&.to_i,
          height: parsed["ImageHeight"]&.to_i,
          captured_at: captured_at,
          title: parsed["ObjectName"] || parsed["Title"],
          description: parsed["Caption-Abstract"] || parsed["Description"],
          camera: parsed["Model"],
          lens: parsed["LensModel"] || parsed["Lens"]
        }
      end
    end

    
    # TODO: maybe clean some trash data files information like the following
    #       produced together by Sigma Photo Pro + Raw Therapee
    # {
    #   "filename": "/home/nick/Photo/Albums/Dnestr/._SDIM0578.tif",
    #   "width": null,
    #   "height": null,
    #   "captured_at": "2026-06-19 00:03:03 +0300",
    #   "title": null,
    #   "description": null,
    #   "camera": null,
    #   "lens": null
    # },
    
    private
    
    # ExifTool presents date and time as "2020:11:01 12:13:03"),
    # that is EXIF (TIFF/JPEG) metadat representation standard
    # partly based on ISO 8601, but using ":" instead of "-"
    #   Time.strptime(exif_string, "%Y:%m:%d %H:%M:%S")
    
    EXIF_TIME_FORMAT = '%Y:%m:%d %H:%M:%S'.freeze
    def exif_time(ts) = Time.strptime(ts, EXIF_TIME_FORMAT)
  end
end

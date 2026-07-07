require "json"
require "tmpdir"
require_relative "basic"
require_relative "exif_tool_runner"

module PhotoStore

  # Recursively traverses master image storage paths, processes extended EXIF 
  # metadata metrics, and compiles a flat JSON database dump inside 
  # the operating system architecture temporary directory tracker.
  class Scanner
    extend ::Basic::Callable

    # Triggers the recursive file scanning and system temporary cache storage.
    #
    # @return [String] absolute path onto the newly generated JSON cache file
    def call
      config = Config.instance
      db_records = []

      # 1. Standardize extension formatting (e.g., '.tif' -> 'tif')
      ext_tokens = config.supported_extensions.map { it.sub(".", "") }
      search_pattern = File.join(
        config.masters_dir, 
        "**", 
        "*.{#{ext_tokens.join(',')}}"
      )

      # 2. Deep recursive folder traversal matching targeted image masks
      Dir.glob(search_pattern).each do |file_path|
        next if File.directory?(file_path)

        # Ingest metadata through the expanded system ExifTool adapter pipeline
        metadata_hash = ExifToolRunner.call(file_path)
        image_key = metadata_hash[:image_key]

        db_records << metadata_hash
      end

      # 3. Construct an isolated filename inside the system shared tmp folder
      cache_file_path = File.join(Dir.tmpdir, PHOTOSTORE_CACHE)

      # 4. Dump the compiled data structure using ultra-fast JSON generation
      File.write(cache_file_path, JSON.pretty_generate(db_records))

      cache_file_path
    end

    PHOTOSTORE_CACHE = 'photostore_cache.json'
  end
end

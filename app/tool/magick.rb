require_relative "../basic"

module Tool

  # Internal infrastructure tool executing fast ImageMagick conversions
  class Magick < ::Basic::CliTool
    executable :magick
    
    # High-speed downscaling optimized for quick browser previews
    def convert_to_thumbnail(source:, destination:)
      cmd = [source, "-resize", "600x400>", "-quality", "75", destination]
      execute_command(*cmd)
    end

    # High-speed bulk downscaling optimized for processing batches of raw photos
    # @param sources [Array<String>] list of full absolute paths to raw files
    # @param destination_dir [String] target path to the temp workspace directory
    def bulk_convert_to_thumbnails(sources:, destination_dir:)
      return if sources.empty?

      # Составляем одну мощную команду ImageMagick для пакетной обработки (mogrify или convert)
      # -path указывает, куда складывать результаты
      # -format jpg автоматически пережмет TIF в легкие джипеги
      cmd = [
        "mogrify",
        "-resize", "600x400>", 
        "-quality", "75", 
        "-path", destination_dir, 
        "-format", "webp"
      ] + sources

      execute_command(*cmd)
    end

  end
end

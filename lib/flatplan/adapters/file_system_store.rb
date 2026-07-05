require "fileutils"
require_relative '../ports'

module Flatplan
  module Adapters
    # Concrete Hexagonal Infrastructure Adapter that connects the abstract
    # Ports::FileStore port directly to the host operating system file system.
    class FileSystemStore < Ports::FileStore
      # Checks if a directory exists on the file system.
      # @param path [String] destination directory path
      # @return [Boolean] true if directory exists
      def directory_exists?(path)
        Dir.exist?(path)
      end

      # Checks if a file exists on the file system.
      # @param path [String] target file path
      # @return [Boolean] true if file exists
      def file_exist?(path)
        File.exist?(path)
      end

      # Extracts the last element of the given path.
      # @param path [String] file path to evaluate
      # @return [String] the trailing path component
      def basename(path)
        File.basename(path)
      end

      # Returns list of file entries inside a target directory.
      # @param path [String] directory path to scan
      # @return [Array<String>] list of files inside the directory
      def list_entries(path)
        return [] unless directory_exists?(path)

        # Filter out Unix navigation shortcuts '.' and '..'
        Dir.entries(path).reject { it == "." || it == ".." }
      end

      # Extracts the extension string from a filename.
      # @param filename [String] target filename
      # @return [String] the extension string (e.g., '.webp')
      def extname(filename)
        File.extname(filename)
      end

      # Safely joins path segments using the host platform separator.
      # @param parts [Array<String>] path segments to assemble
      # @return [String] combined unified path string
      def join_paths(*parts)
        File.join(*parts)
      end

      # Reads plain text contents of a file from disk.
      # @param path [String] source target path to read
      # @return [String] plain text contents of the file
      def read_text_file(path)
        File.read(path)
      end

      # Writes plain text contents directly onto the target disk path.
      # @param path [String] destination target path
      # @param content [String] plain text contents to persist
      # @return [void]
      def write_text_file(path, content)
        # Ensure the parent directory tree exists before writing
        parent_dir = File.dirname(path)
        FileUtils.mkdir_p(parent_dir) unless directory_exists?(parent_dir)

        File.write(path, content)
      end
    end
  end
end

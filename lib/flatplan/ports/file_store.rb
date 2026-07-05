module Flatplan
  module Ports
    # Abstract interface contract defining the explicit capabilities required
    # for directory traversal and manifest persistence within the domain.
    class FileStore
      # @param _path [String] destination directory path
      # @return [Boolean] true if directory exists
      def directory_exists?(_path)
        raise NotImplementedError, "#{self.class} must implement #directory_exists?"
      end

      # @param _path [String] destination file path
      # @return [Boolean] true if file exists
      def file_exist?(_path)
        raise NotImplementedError, "#{self.class} must implement #file_exists?"
      end
       
      # @param _path [String] file path to evaluate
      # @return [String] the last element of the path
      def basename(_path)
        raise NotImplementedError, "#{self.class} must implement #basename"
      end

      # @param _path [String] directory path to scan
      # @return [Array<String>] list of files inside the directory
      def list_entries(_path)
        raise NotImplementedError, "#{self.class} must implement #list_entries"
      end

      # @param _filename [String] target filename
      # @return [String] the extension string (e.g., '.webp')
      def extname(_filename)
        raise NotImplementedError, "#{self.class} must implement #extname"
      end

      # @param _parts [Array<String>] path segments to assemble
      # @return [String] combined unified path string
      def join_paths(*_parts)
        raise NotImplementedError, "#{self.class} must implement #join_paths"
      end

      # @param _path [String] source target path to read
      # @return [String] plain text contents of the file
      def read_text_file(_path)
        raise NotImplementedError, "#{self.class} must implement #read_text_file"
      end
       
      # @param _path [String] destination target path
      # @param _content [String] plain text contents to persist
      # @return [void]
      def write_text_file(_path, _content)
        raise NotImplementedError, "#{self.class} must implement #write_text_file"
      end
    end
  end
end

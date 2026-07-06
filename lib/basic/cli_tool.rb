require "open3"

module Basic

  # Abstract infrastructure base class for securely orchestrating external
  # system command-line utilities (like ExifTool or ImageMagick).
  class CliTool
    protected

    # Executes an external shell command securely using Open3 capture mechanics.
    #
    # @param command [String] the binary name or full command string
    # @param args [Array<String>] collection of clean arguments
    # @return [String] raw standard output text from the command execution
    # @raise [RuntimeError] if the system utility returns a non-zero exit status
    def execute_command(command, *args)
      stdout, stderr, status = Open3.capture3(command, *args)

      unless status.success?
        raise "CLI Tool [#{command}] execution failed! " \
              "Exit status: #{status.exitstatus}. Reason: #{stderr.strip}"
      end

      stdout
    end
  end
end

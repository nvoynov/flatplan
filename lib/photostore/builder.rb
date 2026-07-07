require_relative 'exif_tool_runner'

module PhotoStore

  # Recursively traverses master image storage paths, processes extended EXIF 
  # metadata metrics, and compiles a flat JSON database dump inside 
  # the operating system architecture temporary directory tracker.
  class Builder
    extend ::Basic::Callable

    def initialize
      @config = Config.instance
    end
    
    # @return [Hash<Symbol, Image>]
    def call
      # create datastore directory when it does not exist
      dir = File.dirname(@config.datastore)
      Dir.mkdir(dir) unless Dir.exist?(dir)

      records = 
        if File.exist?(@config.datastore)
          JSON.load_file(@config.datastore, {symbolize_names: true})
        else
          ExifToolRunner.call
            .tap{ File.write(@config.datastore, JSON.pretty_generate(it)) }
        end
      
      # TODO: try to mix absent data from other sources, 
      records
        .map{ Image.new(**it) }
        .map{ [ File.basename(it.filename, '.*').to_sym, it ] }
        .to_h
    end
  end
end

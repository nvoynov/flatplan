require_relative 'scanner'

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

      # call scanner when datastore does not exist
      unless File.exist?(@config.datastore)
        tempfile = Scanner.call
        FileUtils.cp tempfile, @config.datastore 
      end
        
      # TODO: try to mix absent data from other sources, 
      #       like Flatplan Series that have image title
      # load datastore and make the result
      JSON
        .load_file(@config.datastore, {symbolize_names: true})
        .map{ Image.new(**it) }
        .map{ [ File.basename(it.filename, '.*').to_sym, it ]}
        .to_h
    end

  end
end

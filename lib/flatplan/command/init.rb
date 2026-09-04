require 'json'
require 'fileutils'
require_relative 'base'

module Flatplan
  module Command

    # Negatives cli app
    class Negatives < Basic::CliTool
      executable :negatives
      def call(...)
        super(...)
          .then{ JSON.parse(it, {symbolize_names: true}) }
          .map { [File.basename(it.delete(:filename).to_s, '.*'), it] }
          .to_h
      end
    end
    
    # Creates initial story manifest of MediaAssets collection
    class Init < Base
      class << self
        def web = new(Medium::Web::Factory.new, Medium::Web::Serializer.new) 
        def book = new(Medium::Book::Factory.new, Core::StorySerializer.new)
      end
      
      def initialize(factory, serializer)
        @factory = factory
        @serializer = serializer
        @negatives = Negatives.new
        super()
      end

      # @param directory [String] target images directory
      # @param keywords [Array<String>] context keywords
      # @return [String] the absolute path to written mainfiest file
      def call(directory, keywords = [], manifest_name: nil)
        raise ArgumentError, "Target directory does not exist: #{directory}" \
          unless Dir.exist?(directory)

        dirkey = File.basename(directory)
        manifest = File.join(config.stories_dir, manifest_name || "#{dirkey}.md")
        return manifest if File.exist?(manifest)

        title = dirkey.capitalize
        filenames = glob_filenames(directory)
        filekeys = filenames.map{ File.basename(it, '.*') }
        metadata = call_negatives(filekeys)
        
        assets = filenames.map do |filepath|
          key = File.basename(filepath, '.*')
          captured_at = metadata[key]&.fetch(:captured_at)
          captured_at = captured_at ? Time.new(captured_at) : Time.now
          @factory.media(filepath, captured_at:)
        end

        elements = [ @factory.media_assets(assets) ]
        
        story = @factory.story(title,
          author: config.author,
          date: Time.now,
          elements:, keywords:)
        
        FileUtils.mkdir_p File.dirname(manifest)  
        @serializer.serialize(story)  
          .then{ File.write(manifest, it) }

        manifest
      end

      protected

      def glob_filenames(directory)
        config.image_extensions.join(?,)
          .then{ File.join(directory ,"**/*.{#{it}}") }
          .then{ Dir.glob(it) }
      end

      def call_negatives(keys) = @negatives.call(*keys)
      
    end
  end
end

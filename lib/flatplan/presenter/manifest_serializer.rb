require_relative '../callable'

module Flatplan
  module Presenter
    # Serializes a domain SeriesPublication entity back into a clean, human-readable
    # Flatplan Markdown publishing manifest file using the uniform Callable interface.
    class ManifestSerializer
      extend Callable

      # Formats a SeriesPublication object into a Markdown string template.
      #
      # @param publication [Model::SeriesPublication] the source domain entity
      # @return [String] formatted Markdown manifest ready to be saved to disk
      def call(publication)
        buffer = []
        
        # 1. Generate Metadata Headers
        buffer << "% #{publication.title}"
        buffer << "% #{publication.author || 'Unknown Author'}"
        buffer << "% #{publication.date || Time.now.strftime('%Y-%m-%d')}\n"
        buffer << "# #{publication.title}\n"
        
        # 2. Add short description if available
        buffer << "#{publication.description}\n" if publication.description

        # 3. Process Sections in sequential order
        publication.sections.each_with_index do |section, index|
          buffer << "---" if index > 0 # Inject pause separators between blocks
          
          if section.is_a?(Model::TextAndMediaSection)
            buffer << "## Section Layout Block"
            buffer << "text: #{section.text_alignment}"
            buffer << "media: #{section.media_alignment}\n"
            
            section.paragraphs.each { |p| buffer << "#{p}\n" }
            buffer << "" unless section.paragraphs.empty?
            
            section.media_assets.each do |asset|
              buffer << "![#{asset.caption}](#{asset.filename})"
            end
            buffer << ""
          end
        end

        buffer.join("\n")
      end
    end
  end
end

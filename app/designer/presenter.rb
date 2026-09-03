# frozen_string_literal: true

module Designer
  # Application-layer presenter responsible for flattening the strict, deeply nested
  # Story domain model into a shallow, predictable JSON-friendly structure optimized 
  # for the drag-and-drop user interface.
  class Presenter
    class << self
      # Transforms a strict domain model (or its primitive hash representation) 
      # into a flat block-based UI layout schema.
      # @param story_model [Object] the Story domain model responsive to #to_h
      # @return [Hash] flattened UI state configuration
      def call(story_model)
        raw_json = story_model.to_h
        story_data = raw_json[:data] || {}

        # GUARANTEE: Ensure blocks are explicitly collected into a clean Ruby Array
        ui_blocks = (story_data[:elements] || []).map do |element|
          element_data = element[:data] || {}
          
          # Safely extract text payload if present
          text_payload = element_data[:text] ? element_data[:text][:data] : {}
          text_body = text_payload[:body] || ""

          # UNIVERSAL EXTRACTION: Support both element-level media and metadata-nested assets
          media_payload = element_data[:media_assets] ? element_data[:media_assets][:data] : {}
          raw_assets = media_payload[:assets] || element_data[:assets] || []

          # Isolate medium-specific layout attributes (metadata/medium_spec)
          # by filtering out pure content fields at both element and layout levels
          metadata = element_data.dup.delete_if { |k, _| %i[text media_assets assets].include?(k) }
          media_grid_spec = media_payload.dup.delete_if { |k, _| k == :assets }
          metadata.merge!(media_grid_spec)

          # Flatten media assets into an easy-to-map array for SortableJS pool
          media_assets = raw_assets.map do |asset|
            asset_data = asset[:data] || asset || {}
            filename = File.basename(asset_data[:filepath].to_s)
            thumb_name = "#{File.basename(asset_data[:filepath].to_s, '.*')}.webp"

            # Enrich asset payload with pure UI fields needed for rendering thumbnails
            {
              filepath: asset_data[:filepath] || "",
              captured_at: asset_data[:captured_at] || null,
              caption: asset_data[:caption] || "",
              alt: asset_data[:alt] || "",
              width: asset_data[:width] || nil,
              height: asset_data[:height] || nil,
              size: asset_data[:size] || "standard",
              filename: filename,
              thumb_url: "/#{thumb_name}" # Flattened routes compatibility token
            }
          end

          {
            type: element[:type],
            metadata: metadata,
            text_body: text_body,
            media_assets: media_assets
          }
        end

        {
          title: story_data[:title] || "",
          author: story_data[:author] || "",
          slug: story_data[:slug] || "",
          description: story_data[:description] || "",
          date: story_data[:date] || nil,
          blocks: ui_blocks # Will compile into a proper JSON array bracket []
        }
      end
    end
  end
end

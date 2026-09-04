# frozen_string_literal: true

module Designer
  class Presenter
    class << self
      def call(story_model)
        raw_json = story_model.to_h
        story_data = raw_json[:data] || {}

        ui_blocks = (story_data[:elements] || []).map do |element|
          element_data = element[:data] || {}
          
          # 1. UNIVERSAL IMAGE EXTRACTION FOR THE UI POOL
          media_payload = element_data[:media_assets] ? element_data[:media_assets][:data] : {}
          raw_assets = media_payload[:assets] || element_data[:assets] || []

          media_assets = raw_assets.map do |asset|
            asset_data = asset[:data] || asset || {}
            filename = File.basename(asset_data[:filepath].to_s)
            {
              filepath: asset_data[:filepath] || "",
              filename: filename,
              thumb_url: "/#{filename.split('.').shift()}.webp"
            }
          end

          # 2. ISOLATE PROPERTIES FOR THE INSPECTOR WHEEL
          # We extract columns, flow, text_position etc., dynamically
          metadata = element_data.dup.delete_if { |k, _| %i[text media_assets assets].include?(k) }
          media_grid_spec = media_payload.dup.delete_if { |k, _| k == :assets }
          metadata.merge!(media_grid_spec)

          {
            type: element[:type],
            text_body: (element_data[:text] ? element_data[:text][:data][:body] : "") || "",
            metadata: metadata,
            media_assets: media_assets,
            # MAGIC LINK: Keep the absolute untouched original snapshot for the builder
            origin: element 
          }
        end

        {
          title: story_data[:title] || "",
          author: story_data[:author] || "",
          slug: story_data[:slug] || "",
          description: story_data[:description] || "",
          date: story_data[:date] || nil,
          blocks: ui_blocks
        }
      end
    end
  end
end

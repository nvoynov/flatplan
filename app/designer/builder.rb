# frozen_string_literal: true

require_relative '../basic'

module Designer
  # Application-layer builder responsible for catching mutated, flat UI layouts 
  # from the frontend and reconstructing them into a deeply nested, strictly typed 
  # hash contract compatible with the Core domain Model initialization (`from_h`).
  class Builder
    class << self
      # Compiles a shallow block structure payload back into a standard domain tree.
      # @param ui_payload [Hash] mutated flat JSON payload received from the browser
      # @return [Object] domain model object
      def call(ui_payload)
        # Reconstruct structural domain elements from the flat layout array
        elements = (ui_payload[:blocks] || []).map do |block|
          metadata = block[:metadata] || {}

          # Rebuild nested Media objects, stripping away temporary UI fields
          rebuilt_assets = (block[:media_assets] || []).map do |asset|
            clean_asset_data = asset.dup.delete_if { |k, _| %i[filename thumb_url id].include?(k) }
            {
              type: "Medium::Web::Media",
              data: clean_asset_data
            }
          end

          {
            type: block[:type],
            data: {
              text: {
                type: "Medium::Web::Text",
                data: {
                  body: block[:text_body] || "",
                  alignment: metadata[:text_alignment] || "left",
                  width_category: metadata[:text_width_category] || "narrow"
                }
              },
              media_assets: {
                type: "Medium::Web::MediaAssets",
                data: {
                  assets: rebuilt_assets,
                  columns: metadata[:columns] || 2,
                  aspect_mode: metadata[:aspect_mode] || "natural"
                }
              },
              # Re-map medium-specific layout specifications back to the element scope
              text_position: metadata[:text_position] || "left",
              flow: metadata[:flow] == true
            }
          }
        end

        Medium::Web::Page.from_h({
          type: "Medium::Web::Page",
          data: {
            title: ui_payload[:title] || "",
            author: ui_payload[:author] || "",
            slug: ui_payload[:slug] || "",
            description: ui_payload[:description] || "",
            date: ui_payload[:date] || nil,
            elements: elements
          }
        })
      end
    end
  end
end


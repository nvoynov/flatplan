# frozen_string_literal: true

module Designer
  class Builder
    class << self
      def call(ui_payload)
        payload = ui_payload.transform_keys(&:to_sym) rescue ui_payload
        
        elements = (payload[:blocks] || []).map do |block|
          block = block.transform_keys(&:to_sym)
          ui_metadata = (block[:metadata] || {}).transform_keys(&:to_sym)
          
          # 1. RECOVER ORIGIN: Extract the pure untouched domain structure hash
          origin_element = block[:origin].transform_keys(&:to_sym) rescue block[:origin]
          origin_data = origin_element[:data].transform_keys(&:to_sym)

          # 2. CLEAN UP MODIFIED IMAGES POOL
          rebuilt_assets = (block[:media_assets] || []).map do |asset|
            asset = asset.transform_keys(&:to_sym)
            asset.delete_if { |k, _| %i[filename thumb_url id].include?(k) }
            { type: "Medium::Web::Media", data: asset }
          end

          # 3. UNWRAP AND MUTATE PROPERLY
          # If original model has deep structural nesting for media grid parameters:
          if origin_data[:media_assets]
            origin_data[:media_assets][:data][:assets] = rebuilt_assets
            # Inject grid specifications (like columns, aspect_mode) to their native deep scope
            origin_data[:media_assets][:data][:columns] = ui_metadata.delete(:columns) || 2
            origin_data[:media_assets][:data][:aspect_mode] = ui_metadata.delete(:aspect_mode) || "natural"
          end

          # Merge remaining properties (flow, text_position) directly back into element regular data fields
          origin_data.merge!(ui_metadata)

          {
            type: origin_element[:type],
            data: origin_data
          }
        end

        {
          type: "Medium::Web::Page",
          data: {
            title: payload[:title] || "",
            author: payload[:author] || "",
            slug: payload[:slug] || "",
            description: payload[:description] || "",
            date: payload[:date] || nil,
            elements: elements
          }
        }
      end
    end
  end
end

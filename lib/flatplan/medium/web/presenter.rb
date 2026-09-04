# frozen_string_literal: true

require_relative '../../../basic'

module Flatplan
  module Medium
    module Web
      # Translates a modern Web::Page object graph into highly structured, 
      # semantic Pandoc Markdown utilizing fenced divs with flatplan_ prefixes.
      class Presenter

        # @param path_modifier [Hash, nil] rules to modify image paths on the fly (e.g., ext: '.jpg', dir: '')
        # @param kwargs [Hash] additional frontmatter metadata 
        def initialize(path_modifier: nil, **kwargs)
          @path_modifier = path_modifier
          @page_metadata = kwargs
        end
        
        # Main entry point to serialize a page into Pandoc-compliant Markdown.
        # @param page [Flatplan::Medium::Web::Page]
        # @return [String]
        def serialize(page)
          header = {
            title: page.title,
            author: page.author,
            date: page.date,
            description: page.description
          }.then{
            @page_metadata.any? ? it.merge(@page_metadata) : it
          }.then{
            <<~FRONTMATTER
              ---
              #{it.map{|k, v| "#{k}: #{v.to_s.inspect}" }.join("\n")}
              ---
            FRONTMATTER
          }
          
          body = page.elements
            .map { render_element(it) }
            .join("\n\n")
          
          "#{header}\n#{body}\n"
        end

        private

        # Polymorphic router for web layout elements
        def render_element(element)
          case element
          when Flatplan::Medium::Web::TextAndMedia
            render_text_and_media(element)
          when Flatplan::Medium::Web::Text
            render_standalone_text(element)
          when Flatplan::Medium::Web::MediaAssets
            render_standalone_grid(element)
          else
            ""
          end
        end

        # Encapsulates a composite TextAndMedia block into fenced divs.
        # Supports modern presentation properties: text_position (adjust) and flow.
        def render_text_and_media(block)
          flow_class = block.flow ? "flatplan_flow_true" : "flatplan_flow_false"
          
          html = []
          html << "::: {.flatplan_section .flatplan_layout_#{block.text_position}_text .#{flow_class}}"
          html << ""
          
          html << "::: {.flatplan_story_text .flatplan_width_#{block.text.width_category}}"
          html << block.text.body
          html << ":::"
          html << ""
          
          html << render_grid_content(block.media_assets)
          
          html << ":::" 
          html.join("\n")
        end

        # Standalone text block rendering
        def render_standalone_text(block)
          <<~MARKDOWN
            ::: {.flatplan_section .flatplan_text_only .flatplan_align_#{block.alignment} .flatplan_width_#{block.width_category}}
            #{block.body}
            :::
          MARKDOWN
        end

        # Standalone image grid rendering
        def render_standalone_grid(grid)
          <<~MARKDOWN
            ::: {.flatplan_section}
            #{render_grid_content(grid)}
            :::
          MARKDOWN
        end

        # Shared helper to generate a media assets grid with modern aspect_mode and columns count
        def render_grid_content(grid)
          html = []
          html << "::: {.flatplan_media_grid .flatplan_cols_#{grid.columns} .flatplan_aspect_#{grid.aspect_mode}}"
          
          grid.assets.each do |media|
            display_path = modify_path(media.filepath)
            asset_id = File.basename(media.filepath, '.*')
            # wrap images to isolated div, sipping spaces
            html << "::: {.flatplan_image_cell \##{asset_id}}"
            html << "![#{media.alt}](#{display_path} \"#{media.caption}\")"
            html << ":::"
            html << ""
          end
          
          html << ":::"
          html.join("\n")
        end

        # Dynamically alters image path according to preview parameters without mutating the object state.
        def modify_path(original_path)
          return original_path unless @path_modifier

          filename = File.basename(original_path, '.*')
          ext = @path_modifier.fetch(:ext, File.extname(original_path))
          dir = @path_modifier.key?(:dir) ? @path_modifier[:dir] : File.dirname(original_path)

          dir.empty? ? "#{filename}#{ext}" : File.join(dir, "#{filename}#{ext}")
        end
      end
    end
  end
end

# frozen_string_literal: true
require 'yaml'

module Flatplan
  module Core

    # Parsing helper
    module Parser
      extend self
      
      def visual_pause?(line)
        line == '---' || line == '<!-- visual_pause -->'
      end
      
      PROPERTY_LINE = /^([a-z_]+)\s*:\s*(.+)$/

      def property?(line) = line =~ PROPERTY_LINE
      def property(line)
        match = line.match(PROPERTY_LINE)
        return unless match

        { match[1].to_sym => match[2].strip }
      end

      # @param lines [Array<String>]
      # @return [Array<Object>] where the first is text string,
      #   the last is other content lines
      def text(lines)
        lines_copy = Array.new(lines)
        string = String.new
        
        next_line = proc {
          line = lines_copy.first
          property?(line) || image?(line) ? nil : line
        }

        string << lines_copy.shift while next_line.()
        [ string, lines_copy ]
      end
        
      # @param lines [Array<String>]
      # @return [Array<Object>] where the first item is a Hash of properties
      #   and the second one is other content lines
      def properties(lines)
        lines_copy = Array.new(lines)
        props = {}
        next_property = proc {
          line = lines_copy.first
          property?(line) ? line : nil
        }

        props.merge!(property(lines_copy.shift)) while next_property.()        
        [ props, lines_copy ]
      end

      IMAGE_LINE = /!\[(.*?)\]\((.*?)\)/
      def image?(line) = line =~ IMAGE_LINE
      def image(line)
        match = line.match(IMAGE_LINE)
        return unless match

        {
          filepath: match[2].to_s,
          properties: {
            caption: match[1].to_s
          }
        }        
      end
      
      # Robust frontmatter extractor clearing empty spacing
      def frontmatter(lines)
        cleaned_lines = lines.drop_while { |l| l.strip.empty? }
        return [{}, lines] unless cleaned_lines.first&.strip == '---'

        frontmatter_lines = []
        content_lines = []
        in_frontmatter = true

        cleaned_lines.drop(1).each do |line|
          if in_frontmatter && line.strip == '---'
            in_frontmatter = false
            next
          end
          in_frontmatter ? frontmatter_lines << line : content_lines << line
        end

        begin
          meta = YAML.load(frontmatter_lines.join("\n")) || {}
          [meta.transform_keys(&:to_sym), content_lines]
        rescue StandardError
          [{}, lines]
        end
      end
  
      # Slices plain lines array into blocks bounded by headers or standalone pauses.
      def topics(lines)
        topics = []
        current_topic = []

        lines.each do |line|
          cleaned_line = line.strip
          
          if cleaned_line == '---' || cleaned_line == '<!-- visual_pause -->'
            topics << current_topic unless current_topic.empty?
            current_topic = []
            topics << [line]
          elsif cleaned_line.start_with?('#')
            topics << current_topic unless current_topic.empty?
            current_topic = [line]
          else
            current_topic << line
          end
        end
        topics << current_topic unless current_topic.empty?
        topics
      end
    end
  end
end

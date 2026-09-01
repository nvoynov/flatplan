# frozen_string_literal: true

require 'optparse'
require 'tmpdir'
require 'fileutils'
require_relative '../basic'
require_relative 'render_preview'

module CLI
  # Preview command for compiling and launching browser views
  class Preview < ::Basic::CliCommand
    shortcut :p
    summary "Compile a flat manifest into an optimized lightweight browser preview"

    # Triggers options parsing and invokes the preview pipeline.
    def call(argv)
      if argv.empty?
        puts "Error: Story manifest file name or path missing."
        puts
        puts build_parser({})
        exit 64 # EX_USAGE
      end

      options = { medium: :web }
      parser = build_parser(options)
      parse_options!(argv, parser)
      
      execute(argv.first, options[:medium])
    end

    # Public interface hook implementing the baseline parser lookup
    def parser
      build_parser({})
    end

    private

    def build_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: flatplan #{self.class.command_name} <manifest_file> [options]"
        opts.separator ""
        opts.separator "Options:"

        opts.on('-m', '--medium TYPE', %i[web book zine], 
                'Target medium platform for layout rules (web, book)') do |val|
          options[:medium] = val
        end

        opts.on("-h", "--help", "Show help documentation for this subcommand") do
          puts opts
          exit
        end
      end
    end

    def execute(manifest_name, medium)
      warn "#{APP_NAME} > Generating preview ..."
      story_slug = File.basename(manifest_name, '.*')
      preview = RenderPreview.new.call(story_slug:, manifest_path: manifest_name)
      open_browser(preview)
    end
    
    def open_browser(html_path)
      open_command = RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'open' : 'xdg-open'
      system("#{open_command} #{html_path}")
    end
  end
end


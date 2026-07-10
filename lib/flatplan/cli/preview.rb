# lib/flatplan/cli/preview.rb

require_relative "../../basic/cli_command"
require_relative "../service"
require_relative "../presenter"
require_relative "../config"
require_relative "magick_cli"
require_relative "pandoc_cli"

module Flatplan
  module CLI
    # Dedicated Command Object orchestrating terminal visualizations 
    # and dynamic compilation workflows for live web browser previews.
    class Preview < ::Basic::CliCommand
      # One clean declarative macro configures your short command triggers!
      shortcut :p
      summary "Render textual schematic or open full interactive HTML preview"

      # Triggers layout building based on explicit command line options parsing.
      # Pristine, uniform, and strict single-argument signature layout.
      #
      # @param argv [Array<String>] remaining command line arguments slice
      def call(argv)
        config = Config.instance
        
        # 1. Default setup configuration tracking flags
        options = { 
          manifest: config.series_manifest_name, 
          console: true # По умолчанию всегда выводим схему в консоль!
        }
        
        parser = build_parser(options)

        # 2. Seamlessly execute option parsing via the inherited base class tracker
        # This will securely mutate options[:console] to false if -b or --browser is supplied
        parse_options!(argv, parser)

        # 3. Fail-Fast: Validate positional parameters availability after flags parsing
        if argv.empty?
          puts "Error: Path to targeted series directory missing."
          puts
          puts parser
          exit 1
        end

        # 4. Post-parsing: proceed straight to path resolution and execution stages
        series_dir = resolve_and_validate_path!(argv.first, config)

        if options[:console]
          view_flatplan(series_dir, options[:manifest])
        else
          preview_in_browser(series_dir, options[:manifest], config)
        end
      end

      # Public interface hook implementing the baseline parser lookup
      # Defaults to force_browser: false context specifically for documentation display
      def parser
        build_parser({})
      end

      private

      # Factory method isolating OptionParser schema construction using native Ruby 3.4 DSL.
      def build_parser(options)
        OptionParser.new do |opts|
          opts.banner = "Usage: flatplan #{self.class.command_name} <dir> [options]"
          
          opts.separator ""
          opts.separator "Options:"

          opts.on("-m", "--manifest NAME", 
                  "Specify alternative manifest name or shorthand token") do |m|
            options[:manifest] = resolve_manifest_name(m, Config.instance)
          end

          opts.on("-c", "--console", 
                  "Force output render directly inside the console terminal") do
            options[:console] = true
          end

          opts.on("-b", "--browser", 
                  "Force output compilation and open interactive HTML layout in browser") do
            options[:console] = false # Explicitly override and switch layout to browser
          end

          opts.on("-h", "--help", "Show help documentation for this subcommand") do
            puts opts
            exit
          end
        end
      end

      # Core execution routine for terminal visual schematic printing.
      def view_flatplan(series_dir, manifest_name)
        publication = Service::LoadPublication.call(
          directory_path: series_dir, 
          manifest_name: manifest_name
        )
        puts RenderConsoleFlatplan.call(publication)
      end

      # Core execution routine for browser interactive engine compilation pipeline.
      def preview_in_browser(series_dir, manifest_name, config)
        # assets_dir = File.expand_path("../assets", __dir__).freeze
        assets_dir = File.join(Dir.pwd, 'lib', 'assets')
        css_path = File.join(assets_dir, "style.css")

        publication = Service::LoadPublication.call(
          directory_path: series_dir,
          manifest_name: manifest_name
        )
        
        raw_pandoc_markdown = SerializePandocManifest.call(publication)
        pandoc_markdown = raw_pandoc_markdown.gsub(/\.([a-zA-Z0-9]+)\)/, ".webp)")

        project_root = Dir.pwd
        local_tmp_root = File.join(project_root, "tmp")
        
        tmp_dir = File.join(local_tmp_root, "preview_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
        FileUtils.mkdir_p(tmp_dir)
        puts "==> Establishing local pipeline workspace: #{tmp_dir}"
        FileUtils.cp(css_path, tmp_dir)

        begin
          magick_cli = MagickCli.new

          Dir.glob(File.join(series_dir, "*")).each do |item|
            next if File.directory?(item)
            next unless config.image_extensions.include?(File.extname(item).downcase)

            web_filename = File.basename(item, ".*") + ".webp"
            magick_cli.convert_to_thumbnail(
              source: item, 
              destination: File.join(tmp_dir, web_filename)
            )
          end

          File.write(File.join(tmp_dir, "pandoc_manifest.md"), pandoc_markdown)
          puts "==> Triggering system Pandoc core compiler via isolated CliTool..."
          
          PandocCli.new.compile(
            source: "pandoc_manifest.md", 
            stylesheet: "style.css",
            destination: "index.html", 
            workspace: tmp_dir
          )

          tmp_html_path = File.join(tmp_dir, "index.html")
          unless File.exist?(tmp_html_path)
            puts "Error: System Pandoc execution failed. Verify Pandoc setup."
            exit 1
          end

          browse(tmp_html_path)

          puts "==> Preview active. Press Ctrl+C to terminate workspace."
          begin
            sleep
          rescue Interrupt
            puts "\n==> Tearing down local pipeline workspace..."
          end
        ensure
          FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
        end
      end

      # Shorthand to каноническое manifest layout file name converter.
      def resolve_manifest_name(input_name, config)
        return config.series_manifest_name if input_name.nil? || input_name.strip.empty?
        if !input_name.start_with?("SERIES") && !input_name.end_with?(".md")
          "SERIES_#{input_name}.md"
        else
          input_name
        end
      end

      # Expands input paths against the configured system root or the local CWD.
      def resolve_and_validate_path!(input_path, config)
        absolute_path = if input_path.start_with?("~")
                          File.expand_path(input_path)
                        elsif input_path.start_with?("/", "./", "../")
                          File.expand_path(input_path, Dir.pwd)
                        else
                          File.expand_path(input_path, config.series_dir)
                        end

        unless Dir.exist?(absolute_path)
          puts "Error: Target series directory not found at '#{absolute_path}'"
          exit 1
        end
        absolute_path
      end

      # Dispatches the compiled HTML target onto the designated system web browser.
      def browse(path)
        case RbConfig::CONFIG["host_os"]
        when /mswin|mingw|cygwin/ then system("start #{path}")
        when /darwin/             then system("open #{path}")
        when /linux|bsd/
          if system("command -v firefox >/dev/null 2>&1")
            system("firefox #{path} &")
          else
            system("xdg-open #{path}")
          end
        end
      end
    end
  end
end

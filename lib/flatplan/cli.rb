# lib/flatplan/cli.rb

require "fileutils"
require "tmpdir"
require_relative "service"
require_relative "config"
require_relative "banner"
require_relative "cli/magick_cli"
require_relative "cli/pandoc_cli"

module Flatplan
  # Application orchestration layer responsible for handling command line
  # arguments, workspace linkings, and triggering toolchain compilation.
  module CLI
    extend self

    ASSETS_DIR = File.expand_path("../assets", __dir__).freeze
    HELP_USAGE = "Usage:\n  flatplan <dir>          - Show text layout schematic flatplan\n  flatplan preview <dir>  - Open full interactive HTML browser preview".freeze

    def call
      if ARGV.empty?
        puts BANNER + "\n" + HELP_USAGE
        exit
      end

      if ARGV.first == "preview"
        ARGV.shift
        if ARGV.empty?
          puts "Error: Path to directory missing.\n#{HELP_USAGE}"
          exit
        end
        preview(ARGV.first)
      else 
        view_flatplan(ARGV.first)
      end
    end

    private

    # Command 1: Render the core domain flatplan diagram inside the console terminal
    def view_flatplan(series_dir)
      validate_directory!(series_dir)
      CreateInitialManifest.call(directory_path: series_dir)
      
      publication = LoadPublication.call(directory_path: series_dir)
      puts RenderConsoleFlatplan.call(publication)
    end
    
    # Command 2: Trigger the external infrastructure Pandoc preview pipeline
    def preview(series_dir)
      validate_directory!(series_dir)
      css_path = File.join(ASSETS_DIR, "style.css")

      CreateInitialManifest.call(directory_path: series_dir)
      publication = LoadPublication.call(directory_path: series_dir)
      
      raw_pandoc_markdown = SerializePandocManifest.call(publication)
      pandoc_markdown = raw_pandoc_markdown.gsub(/\.([a-zA-Z0-9]+)\)/, ".webp)")

      # 1. Establish an absolute local path inside the stable project root
      project_root = Dir.pwd
      local_tmp_root = File.join(project_root, "tmp")
      
      tmp_dir = File.join(local_tmp_root, "preview_#{Time.now.strftime('%Y%m%d_%H%M%S')}")
      FileUtils.mkdir_p(tmp_dir)
      puts "==> Establishing local pipeline workspace: #{tmp_dir}"
      
      # Copy style template directly into the localized workspace
      FileUtils.cp(css_path, tmp_dir)

      begin
        magick_cli = MagickCli.new

        Dir.glob(File.join(File.expand_path(series_dir, project_root), "*")).each do |item|
          next if File.directory?(item)
          
          ext = File.extname(item).downcase
          next unless config.image_extensions.include?(ext)

          web_filename = File.basename(item, ".*") + ".webp"
          destination_path = File.join(tmp_dir, web_filename)

          magick_cli.convert_to_thumbnail(source: item, destination: destination_path)
        end

        # 2. Write down text sources straight inside the workspace
        File.write(File.join(tmp_dir, "pandoc_manifest.md"), pandoc_markdown)
        puts "==> Triggering system Pandoc core compiler via isolated CliTool..."
        
        # Compile standard HTML linked to the local asset sheet
        PandocCli.new.compile(
          source: "pandoc_manifest.md",
          stylesheet: "style.css", # Имя файла CSS, лежащего прямо внутри tmp_dir!
          destination: "index.html",
          workspace: tmp_dir
        )

        tmp_html_path = File.join(tmp_dir, "index.html")
        unless File.exist?(tmp_html_path)
          puts "Error: System Pandoc execution failed. Verify Pandoc setup."
          exit
        end

        # Open Firefox directly onto the verified local HTML file
        browse(tmp_html_path)

        puts "==> Preview active. Press Ctrl+C to terminate workspace."
        begin
          sleep
        rescue Interrupt
          puts "\n==> Tearing down local pipeline workspace..."
        end
      ensure
        # Clean up the folder footprint upon execution exit
        FileUtils.rm_rf(tmp_dir) if Dir.exist?(tmp_dir)
      end
      puts "==> Pipeline workspace successfully destroyed. Clean execution exit."
    end

    def validate_directory!(dir)
      unless Dir.exist?(dir)
        puts "Error: Target series directory not found at '#{dir}'"
        exit
      end
    end

    def config
      @config ||= Config.instance
    end

    # def browse(pat1h)
    #   # Append '2>/dev/null' to mute OS specific GTK/atk-bridge visual logging noise
    #   case RbConfig::CONFIG["host_os"]
    #   when /mswin|mingw|cygwin/ then system("start #{path}")
    #   when /darwin/             then system("open #{path}")
    #   when /linux|bsd/          then system("xdg-open #{path}")
    #   end
    # end

    def browse(path)
      case RbConfig::CONFIG["host_os"]
      when /mswin|mingw|cygwin/
        system("start #{path}")
      when /darwin/
        system("open #{path}")
      when /linux|bsd/
        # Check if native or snap firefox binary is executable in the system path
        if system("command -v firefox >/dev/null 2>&1")
          # Invoke Firefox directly to safely bypass any xdg-open MIME-type association bugs
          system("firefox #{path} &")
        else
          # Fallback to default system open utility if firefox is missing
          system("xdg-open #{path}")
        end
      end
    end

  end
end

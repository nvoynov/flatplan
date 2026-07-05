require 'fileutils'
require_relative 'service'
require_relative 'config'
require_relative 'banner'
# require_relative 'services'
# require_relative 'services'

module Flatplan
  module CLI
    extend self

    def call
      if ARGV.empty?
        puts BANNER + ?\n + HELP_USAGE 
        exit
      end
      preview(ARGV)
    end

    # preview Flatplan SeriesPublication
    def preview(args)
      
      series_dir = args.shift
      css_path = File.join(ASSETS_DIR, "style.css")
      unless Dir.exist?(series_dir)
        puts "Error: Target series directory not found at '#{series_dir}'"
        exit
      end

      user_manifext = CreateInitialManifest.call(directory_path: series_dir)

      puts "==> Loading and Parsing User Manifest..."
      manifest_content = File.read(user_manifest)
      
      # 1. Compile User Manifest into our rich domain model
      puts "==> Compiling intermediate Pandoc Layout Document..."
      pandoc_markdown = Flatplan::SerializePandocManifest.call(publication)

      # 2. Serialize domain model into the structured Pandoc Markdown specification
      puts "==> Compiling intermediate Pandoc Layout Document..."
      pandoc_markdown = Flatplan::SerializePandocManifest.call(publication)
      
      # 3. Establish an isolated systems workspace tempfolder
      Dir.mktmpdir("flatplan_pipeline_") do |tmp_dir|
        puts "==> Establishing system pipeline workspace: #{tmp_dir}"
  
        # Copy the global css stylesheet template into workspace
        FileUtils.cp(css_path, tmp_dir)
  
        # Recursively symlink or copy all user images into workspace so Pandoc can read them
        Dir.glob(File.join(series_dir, "*")).each do |item|
          next if File.basename(item) == config.manifest_name

          # FileUtils.cp_r(item, tmp_dir)
          # FileUtils.ln_s создает символическую ссылку во временной папке
          # Флаг force: true защитит от ошибок, если ссылка уже существует
          FileUtils.ln_s(item, tmp_dir, force: true)
        end

        tmp_md_path = File.join(tmp_dir, "pandoc_manifest.md")
        tmp_html_path = File.join(tmp_dir, "index.html")
  
        # Write down the generated Pandoc source file
        File.write(tmp_md_path, pandoc_markdown)

        # 4. Invoke native system Pandoc toolchain compiler via clean CLI command execution
        puts "==> Triggering system Pandoc core compiler..."
        pandoc_cmd = "pandoc #{tmp_md_path} -f markdown+fenced_divs -t html5 -s -c style.css -o #{tmp_html_path}"
        system(pandoc_cmd)

        unless File.exist?(tmp_html_path)
          puts "Error: System Pandoc execution failed. Please verify Pandoc setup globally."
          exit
        end

        browse tmp_html_path

        puts "==> Preview active. Temporary assets locked and streaming. Press Ctrl+C to terminate."
        begin
          sleep
        rescue Interrupt
          puts "\n==> Tearing down system pipeline workspace..."
        end
      end

      puts "==> Pipeline workspace successfully destroyed. Clean execution exit."

    end

    ASSETS_DIR = File.expand_path('../assets', __dir__).freeze
    HELP_USAGE = "Usage: flatplan <path_to_series_directory>"  

    def config
      @config ||= Config.instance
    end

    def browse(path)
      case RbConfig::CONFIG["host_os"]
      when /mswin|mingw|cygwin/ then system("start #{path}")
      when /darwin/             then system("open #{path}")
      when /linux|bsd/          then system("xdg-open #{path}")
      end
    end
  end
end

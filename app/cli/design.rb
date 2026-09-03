# frozen_string_literal: true

require 'fileutils'
require_relative '../basic'
require_relative '../server'
require_relative 'render_preview'

module CLI
  # Design command for launching the interactive live markdown workspace
  class Design < ::Basic::CliCommand
    shortcut :d
    summary "Launch the interactive dual-pane live layout editor in your browser"

    def call(argv)
      if argv.empty?
        puts "Error: Story manifest file name or path missing."
        puts
        puts build_parser({})
        exit 64 # EX_USAGE
      end

      options = {}
      parser = build_parser(options)
      parse_options!(argv, parser)
      
      execute(argv.first)
    end

    def parser
      build_parser({})
    end

    private

    def build_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage: flatplan #{self.class.command_name} <manifest_file> [options]"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-h", "--help", "Show help documentation for this subcommand") do
          puts opts
          exit
        end
      end
    end

    def execute(manifest_name)
      $stdout.sync = true
      $stderr.sync = true

      story_slug = File.basename(manifest_name, '.*')
      
      # Первая компиляция, чтобы файлы точно легли в кэш
      RenderPreview.new.call(story_slug: story_slug, manifest_path: manifest_name)

      warn "#{APP_NAME} > Starting Flatplan Design engine on http://localhost:4567"
      
      # Передаем имя активной истории в Синатру через переменную окружения
      ENV['FLATPLAN_CURRENT_STORY'] = story_slug
      
      Server.set :port, 4567
      Server.set :server, 'puma'
      Server.set :logging, true
      
      server_thread = Thread.new do
        Server.run!
      end

      sleep 1

      warn "#{APP_NAME} > Launching browser workspace..."
      open_command = RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'open' : 'xdg-open'
      system("#{open_command} http://localhost:4567/")

      begin
        server_thread.join
      rescue Interrupt
        warn "\n#{APP_NAME} > Design session closed. Goodbye."
        exit 0
      end
    end

  end
end


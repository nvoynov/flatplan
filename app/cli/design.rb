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
      warn "#{APP_NAME} > Generating preview ..."
      story_slug = File.basename(manifest_name, '.*')
      preview = RenderPreview.new.call(story_slug:, manifest_path: manifest_name)

      warn "#{APP_NAME} > Starting Flatplan Design engine on http://localhost:4567"
      
      Server.set :port, 4567
      Server.set :server, 'puma'
      
      server_thread = Thread.new do
        Server.run!
      end

      # Даем серверу 1 секунду, чтобы Puma успела проинициализировать порт
      sleep 1

      # 4. Автоматически открываем браузер на нужной истории
      warn "#{APP_NAME} > Launching browser workspace..."
      open_command = RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'open' : 'xdg-open'
      system("#{open_command} http://localhost:4567/design/#{story_slug}")

      # 5. Блокируем главный поток CLI, чтобы сервер жил, пока пользователь не нажмет Ctrl+C
      begin
        server_thread.join
      rescue Interrupt
        warn "\n#{APP_NAME} > Design session closed. Flushing memory caches. Goodbye."
        exit 0
      end
    end
  end
end


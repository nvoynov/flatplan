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

      watch = options[:watch]
      execute(argv.first, options[:medium], watch:)
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

        opts.on('-m', '--medium TYPE', %i[web book zine], 'Target medium platform for layout rules (web, book)') do |val|
          options[:medium] = val
        end
        
        opts.on('-w', '--watch', 'Watch manifest changes and reload browser live') do
          options[:watch] = true
        end
        
        opts.on("-h", "--help", "Show help documentation for this subcommand") do
          puts opts
          exit
        end
      end
    end
    
    def execute(manifest_name, medium, watch: false)
      story_slug = File.basename(manifest_name, '.*')
      config = Config.instance
      workspace_dir = File.join(config.stories_dir, '.cache', 'preview', story_slug)
  
      $stdout.sync = true
      $stderr.sync = true

      # Проверяем, запущены ли мы внутри сессии ENTR (entr сам выставляет переменную окружения)
      # Если мы внутри entr, нам НЕ нужно заново поднимать сервер и открывать браузер
      is_inside_watch_loop = !ENV['FLATPLAN_LIVE'].nil?

      if is_inside_watch_loop
        puts "#{APP_NAME} > File changed! Re-compiling preview..."
      else
        puts "#{APP_NAME} > Compiling preview..."
      end

      # Подгружаем JS-миксин только для режима watch
      watch_script = if watch 
                       File.read(File.expand_path('../public/js/watch.js', __dir__))
                     else
                       ""
                     end

      # Всегда компилируем HTML и обновляем version.txt
      preview_path = RenderPreview.new.call(
        story_slug: story_slug, 
        manifest_path: manifest_name,
        mixin_script: watch_script 
      )

      # Разделение логики
      if watch && !is_inside_watch_loop
        # === ГЛАВНЫЙ ИНСТАНС НАБЛЮДАТЕЛЯ ===
        puts "#{APP_NAME} > Starting Live Watch mode for #{story_slug}..."
        FileUtils.mkdir_p(workspace_dir)

        # Используем порт 4568, чтобы не мешать Синатре (4567)
        server_port = 4568
    
        # Запускаем встроенный сервер Ruby. 
        # out: File::NULL глушит логи веб-сервера, чтобы они не мешали вашим логам компиляции
        server_pid = spawn("ruby -run -e httpd #{workspace_dir} -p #{server_port}", out: File::NULL, err: File::NULL)
    
        # Даем Puma/WEBrick чуть больше времени раскачаться
        sleep 0.8 
    
        # ЯВНО принуждаем открыть именно HTTP-адрес
        live_url = "http://localhost:#{server_port}/preview.html"
        puts "#{APP_NAME} > Server started on #{live_url}"
        open_browser_url(live_url)

        begin
          # Запускаем entr. Флаг FLATPLAN_LIVE=true будет виден во всех последующих итерациях
          # Флаг -r заставит entr перезагрузиться, если файл будет удален/пересоздан вашим IDE
          cmd = "ls #{manifest_name} | FLATPLAN_LIVE=true entr -r flatplan preview #{manifest_name} -m #{medium} -w"
          system(cmd)
        rescue Interrupt
          # Корректный выход по Ctrl+C
        ensure
          puts "\n#{APP_NAME} > Stopping Live Watch session..."
          if server_pid
            Process.kill('TERM', server_pid) rescue nil
            Process.wait(server_pid) rescue nil
          end
        end

      elsif is_inside_watch_loop
        # === ИТЕРАЦИЯ ВНУТРИ ENTR ===
        puts "#{APP_NAME} > Preview updated inside watch session. [version.txt refreshed]"
        # Ничего больше не делаем, браузер по HTTP-каналу сам перечитает версию и обновится

      else
        # === ОБЫЧНЫЙ СТАТИЧЕСКИЙ РЕЖИМ (Без флага -w) ===
        puts "#{APP_NAME} > Launching static browser preview..."
        open_browser_url(preview_path) # Вот тут открывается file://, и это правильно для статики
      end
    end

    private

    def open_browser_url(target)
      open_command = RbConfig::CONFIG['host_os'] =~ /darwin/ ? 'open' : 'xdg-open'
      system("#{open_command} #{target}")
    end

  end
end


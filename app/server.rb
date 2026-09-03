# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative 'basic'
require_relative 'cli/render_preview'
require_relative 'designer/presenter'
require_relative 'designer/builder'

class Server < Sinatra::Base
  # Родная папка для designer.html, js/designer.js и css/designer.css
  set :public_folder, File.expand_path('public', __dir__)
  
  helpers do
    def config; @config ||= Config.instance; end
    # Читаем активную историю, переданную из CLI-команды flatplan design
    def current_story; ENV['FLATPLAN_CURRENT_STORY']; end
    def manifest_path; File.join(config.stories_dir, "#{current_story}.md"); end
    
    def json_response(data)
      content_type :json
      data.to_json
    end
  end

  # =========================================================================
  # 1. СТАТИКА И ИНТЕРФЕЙС (ОДИН СЕРВЕР)
  # =========================================================================

  # Главная страница Дизайнера
  get '/' do
    send_file File.join(settings.public_folder, 'designer.html')
  end

  # Роут превью: отдает сам скомпилированный HTML-файл из папки кэша
  get '/preview.html' do
    preview_path = File.join(config.stories_dir, '.cache', 'preview', current_story, 'preview.html')
    if File.exist?(preview_path)
      send_file preview_path
    else
      status 404
      "<h3>No preview generated yet.</h3>"
    end
  end

  # ЖЕЛЕЗОБЕТОННЫЙ РОУТ ДЛЯ КАРТИНОК И СТИЛЕЙ PREVIEW
  # Этот единственный роут перехватывает любые относительные запросы из iframe
  # (например, /DP0Q0624.webp или /style.css) и берет их прямо из папки кэша!
  get '/:file' do
    file_path = File.join(config.stories_dir, '.cache', 'preview', current_story, params[:file])
    if File.exist?(file_path)
      send_file file_path
    else
      status 404
    end
  end

  get '/:file' do
    puts params[:file]
    # Находим папку кэша текущей истории
    workspace_dir = File.join(config.stories_dir, '.cache', 'preview', current_story)
    
    # Ищем файл внутри этой папки без учёта регистра букв
    actual_file = Dir.glob(File.join(workspace_dir, '*')).find do |f|
      File.basename(f).downcase == params[:file].downcase
    end

    if actual_file && File.exist?(actual_file)
      send_file actual_file
    else
      status 404
    end
  end
  
  # =========================================================================
  # 2. ЧИСТОЕ REST JSON API
  # =========================================================================

  get '/api/design' do
    story_model = Flatplan::Command::Read.web.call(manifest_path)
    ui_data = Designer::Presenter.call(story_model)
    json_response(ui_data)
  end

  post '/api/save' do
    ui_payload = JSON.parse(request.body.read, symbolize_names: true)
    strict_hash = Designer::Builder.call(ui_payload)
    
    model = ModelClass.from_h(strict_hash)
    Flatplan::Command::Write.web.call(model, manifest_path)
    status 200
  end

  post '/api/preview' do
    ui_payload = JSON.parse(request.body.read, symbolize_names: true)
    strict_hash = Designer::Builder.call(ui_payload)
    model = Medium::Web::Page.from_h(strict_hash)

    raw_manifest_string = Flatplan::Core::Serializer.new.serialize(model)

    CLI::RenderPreview.new.call(
      story_slug: current_story,
      raw_content: raw_manifest_string
    )
    status 200
  end
end

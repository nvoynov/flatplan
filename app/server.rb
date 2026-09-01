# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative 'basic'
require_relative 'cli/render_preview'

class Server < Sinatra::Base
  set :views, File.expand_path('views', __dir__)
  set :public_folder, File.expand_path('public', __dir__)
  
  helpers do
    def config
      # @config ||= Flatplan::Core::Config.instance
      @config ||= Config.instance
    end
  end
  
  # Main Editor window
  get '/design/:story' do
    @story_name = params[:story]
    manifest_path = File.join(config.stories_dir, "#{@story_name}.md")

    redirect to('/') unless File.exist?(manifest_path)

    @manifest_content = File.read(manifest_path)
    erb :designer
  end

  # Отдача скомпилированного превью внутрь iframe
  get '/preview/:story' do
    preview_html_path = File.join(config.stories_dir, '.cache', 'preview', params[:story], 'preview.html')
    
    if File.exist?(preview_html_path)
      send_file preview_html_path
    else
      "<h3>No preview generated yet. Start typing...</h3>"
    end
  end

  # API: Live rendering from textarea buffer
  post '/api/preview/:story' do
    payload = JSON.parse(request.body.read)

    CLI::RenderPreview.new.call(
      story_slug: params[:story],
      raw_content: payload['content']
    )

    status 200
  end

  # API: write manifest to diski (Commit)
  post '/api/save/:story' do
    payload = JSON.parse(request.body.read)
    manifest_path = File.join(config.stories_dir, "#{params[:story]}.md")

    File.write(manifest_path, payload['content'])
    status 200
  end
end


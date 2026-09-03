# frozen_string_literal: true

require 'fileutils'
require_relative '../basic'
require_relative '../tool'

module CLI
  # Medium-agnostic interactor responsible for the unified preview pipeline.
  # Accepts raw text or file paths, statefully processes cold WebP caching,
  # and invokes Pandoc compilation inside a persistent sandbox workspace.
  class RenderPreview
    def initialize(
      reader:    Flatplan::Command::Read.web,
      presenter: WebPresenter.new(path_modifier: { ext: '.webp', dir: '' }),
      pandoc:    Tool::Pandoc.new,
      magick:    Tool::Magick.new
    )
      @reader    = reader
      @presenter = presenter
      @pandoc    = pandoc
      @magick    = magick
    end

    # Orchestrates compilation from raw text payload or physical file.
    # @param story_slug [String] unique identity of the story (e.g. "Almaznoe")
    # @param raw_content [String, nil] text from memory buffer, if present
    # @param manifest_path [String, nil] text from file, if present
    # @return [String] full path to the compiled preview.html
    def call(story_slug:, raw_content: nil, manifest_path: nil, mixin_script: nil)
      config = Config.instance
      workspace_dir = File.join(config.stories_dir, '.cache', 'preview', story_slug)
      FileUtils.mkdir_p(workspace_dir)

      # build domain model
      story_page = if raw_content
                     Medium::Web::Builder.new.build(raw_content)
                   else
                     @reader.call(manifest_path)
                   end

      raw_image_paths = story_page.all_media_assets.map(&:filepath)
      missing_sources = raw_image_paths.select do |path|
        !File.exist?(File.join(workspace_dir, "#{File.basename(path, '.*')}.webp"))
      end

      @magick.bulk_convert_to_thumbnails(sources: missing_sources, destination_dir: workspace_dir) \
        if missing_sources.any?

      # present as Pandoc Markdown
      pandoc_markdown = @presenter.serialize(story_page)

      # mixin JavaScript postMessage handler for iframe
      mixin_script =
        if mixin_script
           <<~HTML
             ```{=html}
             #{mixin_script}
             ```  
           HTML
        else
          ''
        end

      pandoc_page_content = pandoc_markdown + mixin_script
      puts pandoc_page_content
        
      # prepare compilier assets
      File.write(File.join(workspace_dir, 'source.md'), pandoc_page_content)
      
      style_source = File.expand_path('../public/css/style.css', __dir__)
      FileUtils.cp(style_source, File.join(workspace_dir, 'style.css'))

      @pandoc.compile(
        source:      'source.md',
        stylesheet:  'style.css',
        destination: 'preview.html',
        workspace:   workspace_dir
      )

      # NOTE: write timestamp to version.txt
      File.write(File.join(workspace_dir, 'version.txt'), Time.now.to_f.to_s)

      File.join(workspace_dir, 'preview.html')
    end
  end
end


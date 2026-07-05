require_relative 'test_helper'

module Dummy
  extend self

  LOREM_IPSUM = <<~LOREM.strip.lines.map(&:strip).join(?\s).freeze
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  LOREM

  # @return [Array<String>]
  def asset_filenames
    @filenames ||= Set.new.tap do
      mknumber = proc{ rand(0..9999).to_s.rjust(4, ?0)}
      it << "DP2Q#{mknumber.()}.tif" while it.size < 30
    end
  end

  # @return [Array<String>]
  def asset_titles
    @asset_titles ||= begin
      words = String.new(LOREM_IPSUM).split
      
      # Use map to explicitly collect and return the generated string titles array
      (1..asset_filenames.size).map do
        length = [3, 4, 5].sample
        words.sample(length).join(' ').capitalize
      end
    end
  end
  
  # @return [Array<Model::LayoutAsset>]
  def media_assets
    @media_assets ||= asset_filenames
      .map.with_index{|e, index|
        Model::LayoutAsset.new(filename: e,
          caption: asset_titles[index] )
      }
  end
  
  # @return [Model::Publication] with one section
  def series_publication_basic
    @basic_series_publication ||= begin
      publication = Model::SeriesPublication.new(title: 'Basic Publication')
      publication.add_section(
        BuildSection.call(
          :text_and_media,
          media_assets: media_assets.take(8),
          text_alignment: :left,
          media_alignment: :right,
          paragraphs: [LOREM_IPSUM]
      ))
      publication
    end
  end

  # @return [Model::Publication] with two sections and a pause in between
  def series_publication
    @series_publication ||= begin
      visual_pause = BuildSection.call(
        :visual_pause,
        media_assets: [],
        spacing: :large
      )

      text_and_media = 
        BuildSection.call(
          :text_and_media,
          media_assets: media_assets.drop(8).take(5),
          text_alignment: :right,
          media_alignment: :left,
          paragraphs: [LOREM_IPSUM]
      )

      sections = series_publication_basic.sections + [visual_pause, text_and_media]
      series_publication_basic.with(sections: sections)      
    end      
  end
  
  # @return [Model::Publication] with two paused sections and hero
  def series_publication_hero
    @series_publication_hero ||= begin
      hero_section = BuildSection.call(
        :editorial_hero,
        media_assets: media_assets.reverse.take(3)
      )
      
      sections = series_publication.sections + [hero_section]
      series_publication.with(sections: sections)
    end
  end

  def publications
    @publications ||= [
      series_publication_basic,
      series_publication,
      series_publication_hero
    ]
  end
end

# pp Dummy.media_assets

# test/support/dummy.rb

require_relative "test_helper"

module Dummy
  extend self

  LOREM_IPSUM = <<~LOREM.strip.lines.map(&:strip).join(" ").freeze
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  LOREM

  # @return [Array<String>]
  def asset_filenames
    @filenames ||= Set.new.tap do |set|
      mknumber = -> { rand(0..9999).to_s.rjust(4, "0") }
      set << "DP2Q#{mknumber.()}.tif" while set.size < 30
    end.to_a
  end

  # @return [Array<String>]
  def asset_titles
    @asset_titles ||= begin
      words = String.new(LOREM_IPSUM).split
      
      # Collect exactly matching elements for titles mapping
      (1..asset_filenames.size).map do
        length = [3, 4, 5].sample
        words.sample(length).join(" ").capitalize
      end
    end
  end

  def mktime
    year = rand(2020..2024)
    month = rand(1..12).to_s.rjust(2, "0")
    day = rand(1..28).to_s.rjust(2, "0")
    Time.new("#{year}-#{month}-#{day} 12:00:00")
  end
  
  # @return [Array<Flatplan::Model::LayoutAsset>]
  def media_assets
    @media_assets ||= asset_filenames
      .map.with_index do |e, index|
        Flatplan::Model::LayoutAsset.new(
          filename: e,
          caption: "Fallback caption",
          title: asset_titles[index],
          captured_at: mktime
        )
      end
  end

  
  # @return [Flatplan::Model::SeriesPublication] with one section
  def series_publication_basic
    @basic_series_publication ||= begin
      publication = Flatplan::Model::SeriesPublication.new(
        title: "Basic Publication",
        author: "Nikolay Voynov",
        date: "2020-2021",
        location: "Svalovichi, Ukraine",
        keywords: ["fine-art", "documentary", "steppe"],
        description: "A comprehensive baseline test fixture story description."
      )
      
      publication.add_section(
        BuildSection.call(
          :text_and_media,
          media_assets: media_assets.take(8),
          text_alignment: :left,
          media_alignment: :right,
          paragraphs: [LOREM_IPSUM]
        )
      )
      publication
    end
  end

  # @return [Flatplan::Model::SeriesPublication] with two sections and a pause
  def series_publication
    @series_publication ||= begin
      visual_pause = BuildSection.call(
        :visual_pause,
        media_assets: [],
        spacing: :large
      )

      text_and_media = BuildSection.call(
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
  
  # @return [Flatplan::Model::SeriesPublication] with two paused sections and hero
  def series_publication_hero
    @series_publication_hero ||= begin
      # Map reverse slices to ensure unique asset allocations for hero layouts
      hero_assets = media_assets.reverse.take(3).map do |asset|
        Flatplan::Model::LayoutAsset.new(
          filename: asset.filename,
          caption: asset.caption,
          title: asset.title,
          captured_at: asset.captured_at
        )
      end

      hero_section = BuildSection.call(
        :editorial_hero,
        media_assets: hero_assets
      )
      
      sections = series_publication.sections + [hero_section]
      series_publication.with(sections: sections)
    end
  end

  # @return [Array<Flatplan::Model::SeriesPublication>]
  def publications
    @publications ||= [
      series_publication_basic,
      series_publication,
      series_publication_hero
    ]
  end
end

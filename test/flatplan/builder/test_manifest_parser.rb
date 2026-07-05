require_relative "../test_helper"

class ManifestParserTest < Minitest::Test
  def setup
    # Наш эталонный манифест Сваловичей последней компактной редакции
    @manifest_content = <<~MARKDOWN
      % Svalovychi (Two Journeys), Toward The Edge
      % Nikolay Voynov
      % 2020-2021
      
      # The Wild Beekeepers
      text: left
      media: right
        
      Some places call you back, not because they are scenic.

      ![The and honey table](DP2Q2553.webp)
      ![Honey harvest close-up](DP2Q2558.webp) 

      ---

      # Abandoned Railway (Leaving Civilization Behind)
      spacing: large
      media: centered

      ![Overgrown rails track](DP2Q2569.webp) 
      ![Railway switch](DP2Q2575.webp) 
    MARKDOWN

  end

  def publication
    @publication ||= Flatplan::Builder::ManifestParser.call(
      content: @manifest_content)#.tap{ pp it }
  end

  def test_raises_argument_error_for_empty_content
    assert_raises(ArgumentError) do
      Flatplan::Builder::ManifestParser.call(content: "   ")
    end
  end

  def test_parses_publication_metadata_and_title
    assert_equal "Svalovychi (Two Journeys), Toward The Edge", publication.title
    assert_equal 3, publication.sections.size
  end

  def test_parses_text_and_media_section_correctly
    section = publication.sections.first

    assert_kind_of Flatplan::Model::TextAndMediaSection, section
    assert_equal :left, section.text_alignment
    assert_equal :right, section.media_alignment
    
    # Проверяем накопление текста абзацев
    assert_equal 1, section.paragraphs.size
    assert_match(/Some places call you back/, section.paragraphs.first)

    # Проверяем сборку картинок-ассетов
    assert_equal 2, section.media_assets.size
    assert_equal "DP2Q2553.webp", section.media_assets.first.filename
    assert_equal "The and honey table", section.media_assets.first.caption
  end

  def test_parses_visual_pause_section_correctly
    section = publication.sections[1]

    assert_kind_of Flatplan::Model::VisualPauseSection, section
    assert_equal :large, section.spacing

    # В визуальной паузе не должно быть текстовых абзацев
    assert_empty section.paragraphs if section.respond_to?(:paragraphs)
    
    # Картинки паузы должны быть на месте
    # assert_equal 2, section.media_assets.size
    # assert_equal "DP2Q2569.webp", section.media_assets.first.filename
  end
end

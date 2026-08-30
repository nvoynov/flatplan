require_relative '../test_helper'
require_relative 'support/mother_core'
include Flatplan

def fake_config(stories_dir = Dir.pwd)
  ConfigData.new.with(stories_dir:)
end

BOOK_MANIFEST = <<~MARKDOWN.strip
  ---
  title: "Svalovichi: The Land of Quiet Waters"
  author: "Nikolay Voynov"
  description: "A limited edition photographic study of life suspended in time."
  date: "2026-08-27"
  ---

  # TitlePage
  template: minimal_dark
  font: 24

  Svalovichi: The Land of Quiet Waters
  Photographs and text by Nikolay Voynov

  # TextAndMedia
  layout: text_left_images_right
  template: asymmetrical_diptych
  font: 11

  The journey into the Pripyat marshes begins where the roads lose their asphalt. Here, in Svalovichi, the silence is a physical presence, broken only by the rhythmic creak of wooden oars.

  ![](images/01_road.jpg)
  ![](images/02_river.jpg)

  # FullBleedSpread
  template: pan_panoramic

  ![](images/03_landscape_huge.jpg)

  # Text
  page_side: left
  font: 12
  width: optical

  Time behaves differently here. It doesn't flow; it accumulates like sediment at the bottom of an abandoned boat.

  # MediaAssets
  template: quad_grid
  columns: 2

  ![](images/04_detail_lock.jpg)
  ![](images/05_detail_window.jpg)
  ![](images/06_detail_net.jpg)
  ![](images/07_detail_hands.jpg)

  # Colophon
  printer: "ArtPrint Studio, Kyiv"
  paper: "Hahnemühle Photo Rag Matte 188gsm"
  edition: "50 numbered copies"
MARKDOWN

# Returns a programmatic, fully populated domain aggregate compiled
# through the standalone factory architecture for deep unit testing.
#
# @return [Model::SeriesPublication] rich domain model tree
def build_comprehensive_publication
  publication = Flatplan::Model::SeriesPublication.new(
    title: "Svalovychi: Two Journeys, Toward The Edge",
    author: "Nikolay Voynov",
    date: "2020-2021"
  )

  # 1. Block: The Wild Beekeepers (TextAndMedia)
  assets_1 = [
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2553.webp", caption: "Tea and wild honey"),
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2558.webp", caption: "Honey harvest close-up"),
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2554.webp", caption: "The keepers of the craft portrait")
  ]
  section_1 = BuildSection.call(
    :text_and_media,
    media_assets: assets_1,
    text_alignment: :left,
    media_alignment: :right,
    paragraphs: ["Some places call you back, not because they are scenic..."]
  )
  publication.add_section(section_1)

  # 2. Block: Standalone Visual Pause (Pure silence via separator)
  section_2 = BuildSection.call(
    :visual_pause,
    media_assets: [],
    spacing: :large
  )
  publication.add_section(section_2)

  # 3. Block: Overgrown Rails (TextAndMedia with custom spacing)
  assets_3 = [
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2569.webp", caption: "Overgrown rails track"),
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2575.webp", caption: "Railway switch")
  ]
  section_3 = BuildSection.call(
    :text_and_media,
    media_assets: assets_3,
    text_alignment: :left,
    media_alignment: :centered,
    paragraphs: [],
    spacing: :large
  )
  publication.add_section(section_3)

  # 4. Block: Three Frail Fishing Boats (Editorial Hero)
  assets_4 = [
    Flatplan::Model::LayoutAsset.new(filename: "DP2Q2655.webp", caption: "Boats hidden by the reeds")
  ]
  section_4 = BuildSection.call(
    :editorial_hero,
    media_assets: assets_4
  )
  publication.add_section(section_4)

  publication
end


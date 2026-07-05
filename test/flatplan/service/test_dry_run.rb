require_relative "../dummy"

describe 'Manifest Serialize/Load dry-run' do

  it 'must serialize and load manifests' do
    Dummy.publications.each do |origin|
      content = Presenter::ManifestSerializer.call(origin)
      parsed  = Builder::ManifestParser.call(content:)
      pp origin, parsed
      assert_equal origin, parsed      
    end
  end

end

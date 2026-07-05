  # Returns a comprehensive production-grade manifest containing all
  # supported section layouts (TextAndMedia, VisualPause, EditorialHero).
  #
  # @return [String] multi-block publishing manifest
  def comprehensive_svalovichi_manifest
    <<~MARKDOWN
      % Svalovychi: Two Journeys, Toward The Edge
      % Nikolay Voynov
      % 2020-2021

      # The Wild Beekeepers
      text: left
      media: right
        
      Some places call you back, not because they are scenic, but because they 
      hold a quiet, fading truth. Svalovychi is a remote, nearly abandoned 
      village in Ukraine.

      ![Tea and wild honey](DP2Q2553.webp)
      ![Honey harvest close-up](DP2Q2558.webp) 
      ![The keepers of the craft portrait](DP2Q2554.webp) 

      ---

      # Overgrown Rails
      spacing: large
      media: centered

      ![Overgrown rails track](DP2Q2569.webp) 
      ![Railway switch](DP2Q2575.webp) 

      ---

      # The Vessels of Silence
      text: right
      media: left

      Along the way, we met locals from dead-end villages—open, deeply hospitable 
      people ready to give directions, track down a tractor for emergency 
      repairs, or share whatever food they had.

      ![Lonely boat under rain](DP2Q2595.webp)
      ![Two boats under evening sun](DP2Q2604.webp)

      ---

      # Three Frail Fishing Boats
      layout: hero

      > Three frail fishing boats hidden by the reeds.

      ![Boats hidden by the reeds](DP2Q2655.webp)

      ---

      # The Epilogue & The Sacred Ground
      layout: pause
      spacing: medium

      ![Water surface with reflected clouds](DP2Q3253.webp)
      ![Dressed graveyard crosses](DP2Q3271.webp)
    MARKDOWN
  end


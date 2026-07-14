require 'test_helper'
require 'time'
require 'kairos'

class TestKairos < Minitest::Test
  # Test 1: Verifies the basic seasonal layer, days of the week, focus placeholder, and trailing year
  def test_basic_layer_and_focus_placeholder
    # September 15, 2025 is a Monday (mid-autumn)
    time = Time.new(2025, 9, 15, 14, 30)
    result = Kairos.call(time)

    assert_equal "afternoon on Monday [focus], in mid autumn, 2025", result[:basic]
  end

  # Test 2: Verifies multi-layer processing with the appended year
  def test_multiple_contexts_returned_as_hash
    # August 12, 2025 is a Tuesday evening
    time = Time.new(2025, 8, 12, 19, 45)
    result = Kairos.call(time, :urban, :rural)

    assert_includes result.keys, :basic
    assert_equal "evening on Tuesday [focus], in mid summer, 2025", result[:basic]
    assert_equal "evening on Tuesday [focus], during the lively summer terrace season, 2025", result[:urban]
    assert_equal "evening on Tuesday [focus], during the mid-summer haymaking season, 2025", result[:rural]
  end

  # Test 3: Verifies context fallback logic with the appended year
  def test_context_fallback_to_basic_rules
    time = Time.new(2025, 12, 15, 10, 0)
    result = Kairos.call(time, :sea)

    assert_equal "morning on Monday [focus], in mid winter, 2025", result[:sea]
  end

  # Test 4: Verifies dynamic calculation of mobile religious holidays with trailing year
  def test_dynamic_easter_calculation
    # Easter Sunday 2025 fell on April 20th
    easter_time = Time.new(2025, 4, 20, 9, 0)
    result = Kairos.call(easter_time, :religious)

    assert_equal "morning on Sunday [focus], on Easter Sunday, 2025", result[:religious]
  end

  # Test 5: Verifies moon phase calculation during dark hours with trailing year
  def test_night_time_moon_phase_inclusion
    # September 7, 2025 at 23:00 was a radiant full moon night
    full_moon_night = Time.new(2025, 9, 7, 23, 0)
    result = Kairos.call(full_moon_night)

    expected_string = "late evening on Sunday [focus], in early autumn under a radiant full moon, 2025"
    assert_equal expected_string, result[:basic]
  end

  # Test 6: Verifies that moon phases are excluded from daytime descriptions but retain the year
  def test_day_time_excludes_moon_phase
    full_moon_day = Time.new(2025, 9, 7, 12, 0)
    result = Kairos.call(full_moon_day)

    assert_equal "afternoon on Sunday [focus], in early autumn, 2025", result[:basic]
  end
end

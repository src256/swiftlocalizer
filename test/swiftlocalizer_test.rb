# coding: utf-8
require_relative 'test_helper'

class SwiftlocalizerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Swiftlocalizer::VERSION
  end

#  def test_it_does_something_useful
#    assert false
  #  end

  def test_get_localized_strings_from_line_single
    line = 'label1.text = NSLocalizedString("English Label 1", comment: "日本語のラベル1")'
    strings = Swiftlocalizer::Command.get_localized_strings_from_line(line, 'dummy.txt', 100)
    assert_equal(1, strings.size)
#    p strings[0]
    assert_equal("English Label 1,日本語のラベル1,dummy.txt,100", strings[0].to_s)
  end

  def test_get_localized_strings_from_line_multiple
    line = 'label1.text = NSLocalizedString("English Label 1", comment: "日本語のラベル1")NSLocalizedString("English Label 2", comment: "日本語のラベル2")'
    strings = Swiftlocalizer::Command.get_localized_strings_from_line(line, 'dummy.txt', 100)
    assert_equal(2, strings.size)
    assert_equal("English Label 1,日本語のラベル1,dummy.txt,100", strings[0].to_s)
    assert_equal("English Label 2,日本語のラベル2,dummy.txt,100", strings[1].to_s)
  end  
end

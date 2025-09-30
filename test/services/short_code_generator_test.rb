require "test_helper"

class ShortCodeGeneratorTest < ActiveSupport::TestCase
  test "generates a 7-character short code" do
    code = ShortCodeGenerator.generate
    assert_equal 7, code.length
  end

  test "generates unique codes across multiple calls" do
    codes = 50.times.map { ShortCodeGenerator.generate }
    assert_equal codes.length, codes.uniq.length
  end

  test "generates only Base62 characters" do
    code = ShortCodeGenerator.generate
    assert_match(/\A[0-9a-zA-Z]{7}\z/, code)
  end
end

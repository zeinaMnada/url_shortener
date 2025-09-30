require "test_helper"

class Base62Test < ActiveSupport::TestCase
  test "encodes and decodes back to original number" do
    [ 0, 1, 61, 62, 12345, 9999999 ].each do |num|
      encoded = Base62.encode(num)
      decoded = Base62.decode(encoded)
      assert_equal num, decoded, "Failed for number #{num}"
    end
  end

  test "encode returns correct string for known values" do
    assert_equal "0", Base62.encode(0)
    assert_equal "a", Base62.encode(10)
    assert_equal "Z", Base62.encode(61)
    assert_equal "10", Base62.encode(62)
  end

  test "decode returns correct number for known values" do
    assert_equal 0, Base62.decode("0")
    assert_equal 10, Base62.decode("a")
    assert_equal 61, Base62.decode("Z")
    assert_equal 62, Base62.decode("10")
  end
end

require "test_helper"

class UrlValidatorTest < ActiveSupport::TestCase
  test "validates correct URLs" do
    assert UrlValidator.valid?("http://example.com")
    assert UrlValidator.valid?("https://rubyonrails.org")
  end

  test "rejects invalid URLs" do
    refute UrlValidator.valid?("ftp://example.com")
    refute UrlValidator.valid?("not-a-url")
    refute UrlValidator.valid?("")
    refute UrlValidator.valid?(nil)
  end
end

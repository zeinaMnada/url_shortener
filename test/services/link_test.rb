require "test_helper"

class LinkTest < ActiveSupport::TestCase
  def setup
    @base_url = "http://example.com"
  end

  test "encode returns short url for valid long_url" do
    long_url = "https://rubyonrails.org"
    result = Link.encode(long_url, @base_url)

    assert result[:success]
    assert_match %r{^#{@base_url}/[a-zA-Z0-9]+$}, result[:short_url]
  end

  test "encode returns error if long_url is missing" do
    result = Link.encode(nil, @base_url)

    refute result[:success]
    assert_includes result[:error], "Missing long_url"
  end

  test "decode returns long_url for existing short code" do
    url = Url.create!(long_url: "https://rubyonrails.org", short_code: "abc1234")
    input = "#{@base_url}/#{url.short_code}"

    result = Link.decode(input)

    assert result[:success]
    assert_equal url.long_url, result[:long_url]
  end

  test "decode returns not found for invalid short_code" do
    result = Link.decode("nonexistent")

    refute result[:success]
    assert_includes result[:error], "Not found"
  end

  test "decode returns error if input missing" do
    result = Link.decode(nil)

    refute result[:success]
    assert_includes result[:error], "Missing short_code"
  end
end

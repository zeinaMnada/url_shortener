require "test_helper"

class UrlTest < ActiveSupport::TestCase
  test "assigns short code when long_url is valid" do
    url = Url.create!(long_url: "https://rubyonrails.org")
    assert url.short_code.present?
    assert_equal 7, url.short_code.length
  end

  test "does not assign short code if long_url is invalid" do
    url = Url.new(long_url: "not-a-url")
    refute url.valid?
    assert_nil url.short_code
  end

  test "persists long_url and short_code correctly" do
    url = Url.create!(long_url: "https://guides.rubyonrails.org")
    found = Url.find_by(short_code: url.short_code)
    assert_equal url.long_url, found.long_url
  end

  test "enforces uniqueness of short_code" do
    url1 = Url.create!(long_url: "https://rubyonrails.org")
    url2 = Url.new(long_url: "https://guides.rubyonrails.org", short_code: url1.short_code)

    refute url2.save
    assert_includes url2.errors[:short_code], "has already been taken"
  end

  test "retries up to 3 times to resolve collisions" do
    duplicate_code = "abc1234"
    Url.create!(long_url: "https://rubyonrails.org", short_code: duplicate_code)

    ShortCodeGenerator.stub :generate, duplicate_code do
      url = Url.new(long_url: "https://example.com")
      refute url.save
      assert_includes url.errors[:short_code], "could not generate a unique short code"
    end
  end
end

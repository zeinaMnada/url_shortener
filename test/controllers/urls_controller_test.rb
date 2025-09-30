
require "test_helper"

class UrlsControllerTest < ActionDispatch::IntegrationTest
  test "POST /encode returns a short code for a valid URL" do
    post "/encode", params: { long_url: "https://rubyonrails.org" }
    assert_response :success

    body = JSON.parse(response.body)
    assert body["short_code"].present?
    assert_equal 7, body["short_code"].length
  end

  test "POST /encode fails for an invalid URL" do
    post "/encode", params: { long_url: "not-a-valid-url" }
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_includes body["errors"], "Long url is not a valid URL"
  end

  test "POST /encode fails when short code cannot be generated after retries" do
    duplicate_code = "abc1234"
    Url.create!(long_url: "https://rubyonrails.org", short_code: duplicate_code)

    ShortCodeGenerator.stub :generate, duplicate_code do
      post "/encode", params: { long_url: "https://example.com" }
      assert_response :unprocessable_entity

      body = JSON.parse(response.body)
      assert_includes body["errors"], "Short url could not generate a unique short code"
    end
  end

  test "POST /decode returns long_url when short_code exists" do
    url = Url.create!(long_url: "https://rubyonrails.org")

    post "/decode", params: { short_code: url.short_code }
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal url.long_url, body["long_url"]
  end

  test "POST /decode returns 404 when short_code does not exist" do
    post "/decode", params: { short_code: "abcdefg" }
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_includes body["error"], "Not found"
  end
end


require "test_helper"
require "minitest/mock"

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
    assert_includes body["error"], "Long url is not a valid URL"
  end

  test "POST /encode fails when short code cannot be generated after retries" do
    duplicate_code = "abc1234"
    original = Url.create!(long_url: "https://rubyonrails.org")
    original.update(short_code: duplicate_code)


    ShortCodeGenerator.stub(:generate, duplicate_code) do
      post "/encode", params: { long_url: "https://example.com" }
      assert_response :unprocessable_entity

      body = JSON.parse(response.body)
      assert_includes body["error"], "Short code has already been taken"
    end
  end

  test "GET /decode returns long_url when short_code exists" do
    url = Url.create!(long_url: "https://rubyonrails.org")

    get "/decode/#{url.short_code}"
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal url.long_url, body["long_url"]
  end

  test "GET /decode returns 404 when short_code does not exist" do
    non_existence_code = "abcdefg"
    get "/decode/#{non_existence_code}"
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_includes body["error"], "Not found"
  end
end

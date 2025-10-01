class UrlsController < ApplicationController
  # POST /encode
  def encode
    url = Url.find_or_create_by(long_url: params[:long_url])
    if url.present? && url.valid?
      full_short_url = "#{request.base_url}/#{url.short_code}"
      render json: { short_url: full_short_url }
    else
      errors = url.present? ? url.errors.full_messages : ""
      render json: { error: errors }, status: :unprocessable_entity
    end
  end

  # GET /decode/:short_code
  def decode
    short_code = extract_code(params[:short_code])
    url = Url.where(short_code: short_code).last
    if url
      render json: { long_url: url.long_url }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  private

  def extract_code(input)
    return "" if input.blank?
    uri = URI.parse(input) rescue nil
    return input unless uri&.path.present?
    uri.path.delete_prefix("/")
  end
end

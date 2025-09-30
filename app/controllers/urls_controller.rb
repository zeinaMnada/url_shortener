class UrlsController < ApplicationController
  # POST /encode
  def encode
    url = Url.find_or_create_by(long_url: params[:long_url])
    if url.present? && url.valid?
      render json: { short_code: url.short_code }
    else
      errors = url.present? ? url.errors.full_messages : ""
      render json: { error: errors }, status: :unprocessable_entity
    end
  end

  # GET /decode/:short_code
  def decode
    url = Url.where(short_code: params[:short_code]).last
    if url
      render json: { long_url: url.long_url }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end
end

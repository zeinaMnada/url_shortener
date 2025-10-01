class UrlsController < ApplicationController
  # POST /encode
  def encode
    result = Link.encode(params[:long_url], request.base_url)

    if result[:success]
      render json: { short_url: result[:short_url] }
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  # GET /decode/:short_code
  def decode
    result = Link.decode(params[:short_code])

    if result[:success]
      render json: { long_url: result[:long_url] }
    else
      render json: { error: result[:error] }, status: :not_found
    end
  end
end

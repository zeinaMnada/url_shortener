class Link
  class << self # using class method for a stateless service
    # Encode a long URL into a short one
    def encode(long_url, base_url)
      return failure("Missing long_url") if long_url.blank?

      url = Url.find_or_create_by(long_url: long_url.strip)
      return failure(url.errors.full_messages) unless url.valid?

      success(short_url: "#{base_url}/#{url.short_code}")
    rescue => e
      failure(e.message)
    end

    # Decode a short URL (or short_code) into its long URL
    def decode(input)
      return failure("Missing short_code") if input.blank?

      short_code = extract_code(input.strip)
      url = Url.find_by(short_code: short_code)
      return failure("Not found") unless url

      success(long_url: url.long_url)
    rescue => e
      failure(e.message)
    end

    private

    def extract_code(input)
      uri = URI.parse(input) rescue nil
      return input unless uri&.path.present?
      uri.path.delete_prefix("/")
    end

    def success(data)
      { success: true }.merge(data)
    end

    def failure(errors)
      { success: false, error: Array(errors) }
    end
  end
end

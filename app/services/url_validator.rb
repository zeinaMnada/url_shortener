class UrlValidator
  URL_REGEX = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

  def self.valid?(url)
    url.present? && url.match?(URL_REGEX)
  end
end

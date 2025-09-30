class Url < ApplicationRecord
  validates :long_url, presence: true
  validate :long_url_must_be_valid

  validates :short_code, uniqueness: true

  # generating short code before validation instead of before create to avoid unnecessary computation if long_url is invalid
  before_validation :assign_short_code, on: :create

  private

  def long_url_must_be_valid
    errors.add(:long_url, "is not a valid URL") unless UrlValidator.valid?(long_url)
  end

  def assign_short_code
    return if errors.any?

    retries = 0
    begin
      self.short_code = ShortCodeGenerator.generate
      retries += 1
    end while Url.exists?(short_code: short_code) && retries < 3

    if Url.exists?(short_code: short_code)
      errors.add(:short_code, "could not generate a unique short code")
    end
  end
end

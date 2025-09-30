class ShortCodeGenerator
  CODE_LENGTH = 7

  def self.generate
    number = SecureRandom.random_number(Base62::BASE**CODE_LENGTH)
    Base62.encode(number).rjust(CODE_LENGTH, "0")
  end
end

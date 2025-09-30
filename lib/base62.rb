module Base62
  CHARSET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  BASE = CHARSET.length

  def self.encode(int)
    return CHARSET[0] if int == 0
    s = ""
    while int > 0
      s << CHARSET[int % BASE]
      int /= BASE
    end
    s.reverse
  end

  def self.decode(str)
    str.chars.reduce(0) { |acc, ch| acc * BASE + CHARSET.index(ch) }
  end
end

# frozen_string_literal: true

class GradeProtectionLevel
  # 0: nothing needed, no account, no guide book, etc.
  # 1: exemple: just need an account (actual default)
  # 2: need engagement, like 'checkbox'
  # 3: need secret question
  # 4: need something like "proof of purchase"
  # 10: no one can see grade
  LEVELS = [ 0, 1, 2, 3, 4, 10 ].freeze
end

# frozen_string_literal: true

class Grade
  GRADE_VALIDATION = %r(^((([1-9][abc]?)|(B[0-9]|B1[0-6])|(E[0-9]|E1[0-1])|(PD|AD|D|TD|ED|ABO)|([I]{1,3}|IV|V[III]{0,3}|IX|X[III]{0,3})|(M|D|VD|S|HS|VS|HVS)|(VB|V[0-9]|V1[0-9]|V20)|(A[0-6])|(5\.[0-9]|5\.1[0-5][abcd]))(\+|-|/-|/\+|\?|\+/\?|-/\?|\+/b|\+/c|a/b|b/c|/[456789][abc]|/A[0123456])?|\?)$).freeze
  GRADE_STYLES = %w[french england usa_lead usa_bouldering deutsch_lead pick_district french_multi_pitch aid].freeze
  MIN_GRADE = 0
  MAX_GRADE = 54

  GRADES_TO_VALUE = [
    # Grade like 1a
    /^(1|1a|1a-|1-|5\.1|M)$/, # 1 : 1a
    /^1a\+$/, # 2 : 1a+
    /^(1b|1b-)$/, # 3 : 1b
    /^1b\+$/, # 4 : 1b+
    /^(1\+|1c|1c-)$/, # 5 : 1c
    /^1c\+$/, # 6 : 1c+

    # Grade like 2a
    /^(2|2-|2a|2a-|5\.2|III-)$/, # 7 : 2a
    /^2a\+$/, # 8 : 2a+
    /^(2b|2b-|D|5\.3|III)$/, # 9 : 2b
    /^2b\+$/, # 10 : 2b+
    /^(2\+|2c|2c-)$/, # 11 : 2c
    /^2c\+$/, # 12 : 2c+

    # Grade like 3a
    /^(3|3-|3a|3a-|5\.4|VB|III\+|B0|PD)$/, # 13 : 3a
    /^(3a\+|V0-)$/, # 14 : 3a+
    /^(3b|3b-|5\.5|V0|IV-|B1)$/, # 15 : 3b
    /^(3b\+|A0)$/, # 16 : 3b+
    /^(3\+|3c|3c-|V0\+|B2)$/, # 17 : 3c
    /^3c\+$/, # 18 : 3c+

    # Grade like 4a
    /^(4|4-|4a|4a-|VD|5\.6|IV|AD-)$/, # 19 : 4a
    /^4a\+$/, # 20 : 4a+
    /^(4b|4b-|S|5\.7|V1|IV\+|AD)$/, # 21 : 4b
    /^(4b\+|A1)$/, # 22 : 4b+
    /^(4\+|4c|4c-|HS|V2|V-|B3|AD\+)$/, # 23 : 4c
    /^4c\+$/, # 24 : 4c+

    # Grade like 5a
    /^(5|5-|5a|5a-|VS|5\.8|V\+|D-)$/, # 25 : 5a
    /^5a\+$/, # 26 : 5a+
    /^(5b|5b-|HVS|5\.9|V3|VI-|D)$/, # 27 : 5b
    /^(5b\+|A2)$/, # 28 : 5b+
    /^(5\+|5c|5c-|5\.10a|VI|D\+)$/, # 29 : 5c
    /^5c\+$/, # 30 : 5c+

    # Grade like 6a
    /^(6|6-|6a|6a-|E1|5\.10b|VI\+|TD-)$/, # 31 : 6a
    /^(6a\+|5.10c|VII-|B4)$/, # 32 : 6a+
    /^(6b|6b-|E2|5\.10d|VII|TD|A3)$/, # 33 : 6b
    /^(6b\+|5\.11a|V4|VII\+|B5)$/, # 34 : 6b+
    /^(6\+|6c|6c-|E3|5\.11b|VIII-|TD\+)$/, # 35 : 6c
    /^(6c\+|5\.11c|V5|VIII|B6)$/, # 36 : 6c+

    # Grade like 7a
    /^(7|7-|7a|7a-|E4|5\.11d|V6|VIII\+|B7|ED-)$/, # 37 : 7a
    /^(7a\+|E5|5.12a|V7|IX-|B8)$/, # 38 : 7a+
    /^(7b|7b-|5\.12b|B9|ED)$/, # 39 : 7b
    /^(7b\+|E6|5\.12c|V8|IX|B10|A4)$/, # 40 : 7b+
    /^(7\+|7c|7c-|5\.12d|V9|IX\+|B11|ED\+)$/, # 41 : 7c
    /^(7c\+|E7|5\.13a|V10|B12)$/, # 42 : 7c+

    # Grade like 8a
    /^(8|8-|8a|8a-|5\.13b|V11|B13|ABO-)$/, # 43 : 8a
    /^(8a\+|E8|5.13c|V12|X-|B14)$/, # 44 : 8a+
    /^(8b|8b-|E9|5\.13d|V13|X|B15|ABO)$/, # 45 : 8b
    /^(8b\+|E10|5\.14a|V14|X\+|B16)$/, # 46 : 8b+
    /^(8\+|8c|8c-|5\.14b|V15|B17|ABO\+)$/, # 47 : 8c
    /^(8c\+|E11|5\.14c|V16|XI-|B18)$/, # 48 : 8c+

    # Grade like 9a
    /^(9|9-|9a|9a-|5\.14d|XI|B19)$/, # 49 : 9a
    /^(9a\+|5.15a|XI\+|B20)$/, # 50 : 9a+
    /^(9b|9b-|5\.15b|XII-)$/, # 51 : 9b
    /^(9b\+|5\.15c|XII)$/, # 52 : 9b+
    /^(9\+|9c|9c-|5\.15d|XII)$/, # 53 : 9c
    /^9c\+$/ # 54 : 9c+
  ].freeze

  GRADES_COLOR = %w[
    rgb(255,85,220) rgb(246,68,211) rgb(238,51,201) rgb(229,34,190) rgb(221,17,180) rgb(212,0,170)
    rgb(134,205,222) rgb(119,198,218) rgb(103,191,213) rgb(87,184,209) rgb(71,178,204) rgb(55,170,200)
    rgb(255,221,84) rgb(252,215,68) rgb(249,208,51) rgb(246,202,34) rgb(243,195,17) rgb(240,189,0)
    rgb(255,127,42) rgb(246,119,34) rgb(238,110,25) rgb(229,102,17) rgb(221,93,8) rgb(212,85,0)
    rgb(170,212,0) rgb(156,195,0) rgb(143,178,0) rgb(129,161,0) rgb(115,144,0) rgb(102,128,0)
    rgb(0,85,212) rgb(0,75,186) rgb(0,64,161) rgb(0,55,136) rgb(0,44,110) rgb(0,34,85)
    rgb(171,55,200) rgb(157,51,184) rgb(144,46,168) rgb(130,42,152) rgb(117,37,136) rgb(103,33,120)
    rgb(255,59,59) rgb(255,42,42) rgb(221,25,25) rgb(204,17,17) rgb(187,8,8) rgb(170,0,0)
    rgb(128,128,128) rgb(102,102,102) rgb(77,77,77) rgb(51,51,51) rgb(25,25,25) rgb(0,0,0)
  ].freeze

  def self.clean_grade(grade)
    grade = grade.strip
    grade = grade.downcase if /^[0-9][abc]/i.match?(grade)
    grade = grade.downcase if /^5\.[0-9]{1,2}[abcd]/i.match?(grade)
    grade = grade.upcase if /^B[0-9]{1,2}/i.match?(grade)
    grade = grade.upcase if /^V/i.match?(grade)
    grade
  end

  def self.valid?(grade)
    return false unless grade

    grade.match?(GRADE_VALIDATION)
  end

  def self.to_value(grade)
    return nil unless grade

    val = MIN_GRADE
    grade = grade.split('/').first
    grade = grade.delete '?'
    GRADES_TO_VALUE.each_with_index do |grade_order, index|
      next unless grade.match? grade_order

      val = index + 1
      break
    end
    val
  end

  def self.grade_color(grade)
    value = Grade.to_value grade
    GRADES_COLOR[value + 1]
  end

  def self.value_color(value)
    GRADES_COLOR[value + 1]
  end

  def self.degree(value)
    return '1' if (1..6).cover? value
    return '2' if (7..12).cover? value
    return '3' if (13..18).cover? value
    return '4' if (19..24).cover? value
    return '5' if (25..30).cover? value
    return '6' if (31..36).cover? value
    return '7' if (37..42).cover? value
    return '8' if (43..48).cover? value
    return '9' if (49..54).cover? value
  end

  def self.level(value)
    return '1a' if (1..2).cover? value
    return '1b' if (3..4).cover? value
    return '1c' if (5..6).cover? value

    return '2a' if (7..8).cover? value
    return '2b' if (9..10).cover? value
    return '2c' if (11..12).cover? value

    return '3a' if (13..14).cover? value
    return '3b' if (15..16).cover? value
    return '3c' if (17..18).cover? value

    return '4a' if (19..20).cover? value
    return '4b' if (21..22).cover? value
    return '4c' if (23..24).cover? value

    return '5a' if (25..26).cover? value
    return '5b' if (27..28).cover? value
    return '5c' if (29..30).cover? value

    return '6a' if (31..32).cover? value
    return '6b' if (33..34).cover? value
    return '6c' if (35..36).cover? value

    return '7a' if (37..38).cover? value
    return '7b' if (39..40).cover? value
    return '7c' if (41..42).cover? value

    return '8a' if (43..44).cover? value
    return '8b' if (45..46).cover? value
    return '8c' if (47..48).cover? value

    return '9a' if (49..50).cover? value
    return '9b' if (51..52).cover? value
    return '9c' if (53..54).cover? value
  end
end

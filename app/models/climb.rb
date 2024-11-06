# frozen_string_literal: true

class Climb
  SPORT_CLIMBING = 'sport_climbing'
  BOULDERING = 'bouldering'
  MULTI_PITCH = 'multi_pitch'
  TRAD_CLIMBING = 'trad_climbing'
  AID_CLIMBING = 'aid_climbing'
  DEEP_WATER = 'deep_water'
  VIA_FERRATA = 'via_ferrata'
  PAN = 'pan'
  SPEED_CLIMBING = 'speed_climbing'

  ALL_LIST = [
    SPORT_CLIMBING,
    BOULDERING,
    MULTI_PITCH,
    TRAD_CLIMBING,
    AID_CLIMBING,
    DEEP_WATER,
    VIA_FERRATA,
    PAN,
    SPEED_CLIMBING
  ].freeze

  CRAG_LIST = [
    SPORT_CLIMBING,
    BOULDERING,
    MULTI_PITCH,
    TRAD_CLIMBING,
    AID_CLIMBING,
    DEEP_WATER,
    VIA_FERRATA
  ].freeze

  GYM_LIST = [
    SPORT_CLIMBING,
    BOULDERING,
    PAN
  ].freeze

  COLOR = {
    SPORT_CLIMBING => '#3a71c7',
    BOULDERING => '#ffcb00',
    MULTI_PITCH => '#ff5656',
    TRAD_CLIMBING => '#e92b2b',
    AID_CLIMBING => '#d40000',
    DEEP_WATER => '#86ccdd',
    VIA_FERRATA => '#3cc770',
    PAN => '#ff5656',
    SPEED_CLIMBING => '#d84315'
  }.freeze

  def self.single_pitch?(climbing_type)
    [SPORT_CLIMBING, BOULDERING, DEEP_WATER, PAN].include? climbing_type
  end

  def self.boltable?(climbing_type)
    [SPORT_CLIMBING, MULTI_PITCH, TRAD_CLIMBING].include? climbing_type
  end

  def self.anchorable?(climbing_type)
    [SPORT_CLIMBING, MULTI_PITCH, TRAD_CLIMBING, AID_CLIMBING].include? climbing_type
  end

  def self.ropable?(climbing_type)
    [SPORT_CLIMBING, MULTI_PITCH, TRAD_CLIMBING, AID_CLIMBING].include? climbing_type
  end

  def self.startable?(climbing_type)
    [BOULDERING].include? climbing_type
  end

  def self.receptionable?(climbing_type)
    [BOULDERING].include? climbing_type
  end
end

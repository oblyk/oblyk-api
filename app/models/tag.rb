# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :taggable, polymorphic: true

  TAGS_LIST = %w[
    crimps
    slopers
    prow
    arete
    slab
    vertical_wall
    overhang
    slight_overhang
    roof
    pockets
    dyno
    traverse
    l_r_traverse
    t_l_traverse
    jugs
    pinches
    dihedral
    chimney
    mantle
    balancy
    physical
    endurance
    resistance
    runout
    compression
    crack
    underclings
    high
    exposed
    pillar
    ledge
    technical
    tiny_crimps
    mono
    jamming
    kneebar
    polished
    dropknee
    heel_hook
    toe_hook
    smearing
    tufas
    yaniro
    flake
    layback
    sidepull
    slots
    morpho
    bouldery_move
    bulge
  ].freeze

  validates :name, presence: true
  validates :taggable_type, inclusion: { in: %w[CragRoute].freeze }
  validates :name, inclusion: { in: TAGS_LIST }
end

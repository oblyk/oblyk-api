# frozen_string_literal: true

class SprayWallHold < ApplicationRecord
  belongs_to :spray_wall, counter_cache: :spray_wall_holds_count, touch: true

  scope :active, -> { where(active: true) }
  default_scope { order(area: :desc) }

  validate :valid_polygon

  before_validation :normalize_points, :compute_geometry
  after_destroy :broadcast_destroy
  after_save :broadcast

  def app_path
    "/gyms/#{spray_wall.gym_id}/spray-walls/#{spray_wall_id}/spray-wall-holds/#{id}"
  end

  def broadcast
    data = SprayWallHoldSerializer.new(self).serializable_hash
    ActionCable.server.broadcast "spray_wall_#{spray_wall_id}.spray_wall_hold", data
  end

  def broadcast_destroy
    data = {
      action: :destroy,
      id: id
    }
    ActionCable.server.broadcast "spray_wall_#{spray_wall_id}.spray_wall_hold", data
  end

  private

  def normalize_points
    return unless points.is_a?(Array)

    self.points = points.map { |x, y| [x.to_f.clamp(0, 1).round(4), y.to_f.clamp(0, 1).round(4)] }
    self.points = points.chunk_while { |a, b| a == b }.map(&:first)
    points.pop if points.size > 1 && points.first == points.last
    points.reverse! if signed_area.positive?
  end

  def signed_area
    points.each_with_index.sum do |(x0, y0), i|
      x1, y1 = points[(i + 1) % points.size]
      x0 * y1 - x1 * y0
    end / 2.0
  end

  def compute_geometry
    return if points.size < 3

    a = signed_area
    return if a.zero?

    cx = cy = 0.0
    points.each_with_index do |(x0, y0), i|
      x1, y1 = points[(i + 1) % points.size]
      cr = x0 * y1 - x1 * y0
      cx += (x0 + x1) * cr
      cy += (y0 + y1) * cr
    end
    self.area = a.abs
    self.cx   = cx / (6 * a)
    self.cy   = cy / (6 * a)
    xs, ys = points.map(&:first), points.map(&:last)
    self.min_x, self.max_x = xs.minmax
    self.min_y, self.max_y = ys.minmax
  end

  def valid_polygon
    return errors.add(:points, "entre 3 et 200 points") unless points.is_a?(Array) && points.size.between?(3, 200)

    errors.add(:points, "aire trop faible") if area.to_f < 1e-6
    errors.add(:points, "contour auto-intersecté") if self_intersecting?
  end

  def self_intersecting?
    # test de croisement des arêtes non adjacentes (O(n²), n ≤ 200 : négligeable)
    n = points.size
    edges = points.each_with_index.map { |p, i| [p, points[(i + 1) % n]] }
    edges.each_with_index.any? do |(a, b), i|
      edges.each_with_index.any? do |(c, d), j|
        next false if (i - j).abs <= 1 || (i.zero? && j == n - 1) || (j.zero? && i == n - 1)

        segments_cross?(a, b, c, d)
      end
    end
  end

  def segments_cross?(a, b, c, d)
    o = ->(p, q, r) { (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]) }
    o.(a, b, c) * o.(a, b, d) < 0 && o.(c, d, a) * o.(c, d, b) < 0
  end
end

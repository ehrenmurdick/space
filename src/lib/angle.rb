module Angle
  class << self

    def rotate_v(angle, vx, vy)
      angle = dtor(angle)
      x = (vx * Math.cos(angle) - vy * Math.sin(angle))
      y = (vx * Math.sin(angle) + vy * Math.cos(angle))
      [x, y]
    end

    def diff(a, b)
      ((((a - b) % 360) + 540) % 360) - 180
    end

    def dtor(deg)
      deg * Math::PI / 180 
    end

    def mag(vx, vy)
      Math.sqrt((vx.abs*vx.abs) + (vy.abs*vy.abs))
    end

    def rtod(rad)
      rad * 180 / Math::PI
    end

    def vtoa(vx, vy)
      rad = Math::atan2(-vx, vy)
      (rtod(rad) + 180) % 360
    end

    def reverse_v(vx, vy)
      (vtoa(vx, vy) + 180) % 360
    end
  end
end

class Laser < Chingu::GameObject
  traits :sprite, :timer
  def initialize(angle, vx, vy)
    self.factor = 0.3
    angle -= 90
    angle %= 360
    @velocity_x = Math.sin(Angle.dtor(angle)) * 12.0
    @velocity_y = Math.cos(Angle.dtor(angle)) * 12.0
    super(:image => "assets/laser.png", :zorder => 150)
  end

  def setup
    after(5000) do
      destroy
    end
  end

  def update
    @x += @velocity_y
    @y += @velocity_x
  end
end

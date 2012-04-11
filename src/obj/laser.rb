require './src/obj/asteroid.rb'
require './src/lib/projectile.rb'
class Laser < Chingu::GameObject
  include Projectile

  def initialize(angle, vx, vy, shooter)
    @shooter = shooter
    angle -= 90
    angle %= 360
    self.radius = 5
    self.power = 5
    @velocity_x = Math.sin(Angle.dtor(angle)) * 12.0
    @velocity_y = Math.cos(Angle.dtor(angle)) * 12.0
    super(:image => "assets/laser.png", :zorder => 150)
    self.factor = 0.8
  end

  def setup
    after(5000) do
      destroy
    end
  end
end

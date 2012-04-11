require './src/obj/asteroid.rb'
class Laser < Chingu::GameObject
  traits :sprite, :timer
  attr_accessor :radius, :power

  def initialize(angle, vx, vy, shooter)
    @shooter = shooter
    self.factor = 0.3
    angle -= 90
    angle %= 360
    self.radius = 5
    self.power = 5
    @velocity_x = Math.sin(Angle.dtor(angle)) * 12.0
    @velocity_y = Math.cos(Angle.dtor(angle)) * 12.0
    @armed = false
    super(:image => "assets/laser.png", :zorder => 150)
  end

  def setup
    after(5000) do
      destroy
    end
  end

  def collide_with(obj)
    obj.hit(power, @shooter)
    dist = Gosu.distance(x, y, $player.x, $player.y)
    Gosu::Sound["sounds/laser_hit.wav"].play(x / (dist * 30))
    destroy
  end

  def update
    @x += @velocity_y
    @y += @velocity_x

    $state.game_objects.each do |obj|
      case obj
      when @shooter
      when Asteroid, Npc, Player
        dist = Gosu.distance(x, y, obj.x, obj.y) 
        if dist < obj.radius
          collide_with(obj)
        end
      end
    end
  end
end

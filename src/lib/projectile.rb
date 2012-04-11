module Projectile
  def self.included(mod)
    mod.class_eval do
      traits :sprite, :timer
      attr_accessor :radius, :power
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

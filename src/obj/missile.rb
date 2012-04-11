require './src/obj/asteroid.rb'
require './src/lib/projectile.rb'
class Missile < Chingu::GameObject
  include Projectile

  def initialize(angle, vx, vy, shooter, target)
    @x, @y = vx, vy
    @target = target
    @shooter = shooter
    @angular = 0
    @rotation = 1
    @speed = 0.8
    angle -= 90
    angle %= 360
    self.radius = 5
    self.power = 15
    super(:image => "assets/missile.png", :zorder => 150)
    self.factor = 0.8
  end

  def update
    @angle += @angular
    

    unless @speed < 0.08
      @speed -= (@speed - 0.08) / 10
    end

    @x += (Math.sin(Angle.dtor(@angle)) / @speed)
    @y -= (Math.cos(Angle.dtor(@angle)) / @speed)

    goal_angle = Angle.vtoa(@target.x + @target.velocity_x - x, @target.y - @target.velocity_y - y)
    turn_to(goal_angle)

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

  def turn_to(goal_angle)
    if Angle.diff(@angle, goal_angle).abs < 5
      @angular = 0
    elsif Angle.diff(@angle, goal_angle) < 0
      @angular = @rotation
    else
      @angular = -@rotation
    end
  end

  def setup
    after(5000) do
      destroy
    end
  end
end

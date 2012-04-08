# If we create classes from Chingu::GameObject we get stuff for free.
# The accessors image,x,y,zorder,angle,factor_x,factor_y,center_x,center_y,mode,alpha.
# We also get a default #draw which draws the image to screen with the parameters listed above.
# You might recognize those from #draw_rot - http://www.libgosu.org/rdoc/classes/Gosu/Image.html#M000023
# And in it's core, that's what Chingu::GameObject is, an encapsulation of draw_rot with some extras.
# For example, we get automatic calls to draw/update with Chingu::GameObject, which usually is what you want. 
# You could stop this by doing: @player = Player.new(:draw => false, :update => false)
#
class Player < Chingu::GameObject
  traits :sprite, :timer
  attr_accessor :angular, :locked, :velocity_x, :velocity_y, :target, :system

  def initialize
    @angular = 0
    @velocity_x, @velocity_y = 0, 0
    @rocket = Gosu::Sample.new("sounds/rocket.wav")
    @laser = Gosu::Sample.new("sounds/laser.wav")
    @animation = Chingu::Animation.new(:file => "assets/ships/bluescout_32x32.png")
    @animation.frame_names = { 
      :drift => 0, 
      :thrust => 1, 
      :drift_left => 2,
      :thrust_left => 3,
      :thrust_right => 4,
      :drift_right => 5}
    @frame_name = "drift"
    @speed_factor = 1
    super
  end

  def setup
    @can_jump = false
    every(500) do
      if !@can_jump && can_jump?
        @can_jump = true
        Gosu::Sound["go.wav"].play
      elsif !can_jump?
        @can_jump = false
      end
    end
  end

  def lock!
    self.locked = true
  end

  def unlock!
    self.locked = false
  end

  def scale_speed(amt)
    @velocity_x = @velocity_x * amt
    @velocity_y = @velocity_y * amt
  end

  def can_jump?
    $state.game_objects.select {|x| x.kind_of?(Planet)}.each do |obj|
      dist = Gosu.distance(x, y, obj.x, obj.y) 
      if dist < 2000
        return false
      end
    end
    true
  end

  def warp
    if !can_jump?
      Gosu::Sound["negative.wav"].play
      return
    end

    Gosu::Sound["charge.wav"].play
    lock!
    after(1000) do
      @speed_factor = 25
      @thruster = true
    end
    after(2300) do
      Gosu::Sound["jump.wav"].play
      if @system == "sol"
        system = "procyon"
      elsif @system == "procyon"
        system = "kruger"
      else
        system = "sol"
      end
      new_state = Space.new(system)
      new_state.player.x = 5000
      new_state.player.y = 5000
      new_state.player.velocity_x = @velocity_x
      new_state.player.velocity_y = @velocity_y
      new_state.player.angle = angle
      new_state.player.slowdown!
      $window.switch_game_state(new_state)
    end
  end

  def start_firing
    unless locked
      fire
      every(150, :name => :fire) do
        fire
      end
    end
  end

  def vx
    @velocity_x
  end

  def vy
    @velocity_y
  end

  def fire
    return if locked
    @laser.play
    shot = Laser.create(angle, vx, vy)
    shot.x = x
    shot.y = y
    shot.factor = 0.1
    shot.angle = angle
  end

  def halt_fire
    stop_timer :fire
  end

  def slowdown!
    lock!
    @speed_factor = 0.5
    after(500) do
      @speed_factor = 1
      unlock!
    end
  end

  def turn_left
    return if locked
    @angular = -1
  end

  def turn_right
    return if locked
    @angular = 1
  end    

  def halt_turn
    @angular = 0
  end

  def accelerate
    return if locked
    @thruster = true
    @r = @rocket.play
    every(9000, :name => "engine") do
      @r && @r.stop
      @r = @rocket.play
    end
  end

  def drift
    @thruster = false
    stop_timer "engine"
    @r && @r.stop
  end

  def reverse
    return if locked
    @reverse = true
  end

  def seek_target
    return if locked
    @seek = true
  end

  def halt_seek
    @seek = false
    @angular = 0
  end

  def halt_reverse
    @reverse = false
    @angular = 0
  end

  def image
    str = ""
    str += "-t1" if @thruster
    str += "-l" if @angular < 0
    str += "-r" if @angular > 0
    Gosu::Image["assets/player#{str}.png"]
  end

  def angle_diff(a, b)
    ((((a - b) % 360) + 540) % 360) - 180
  end

  def update
    @angle += (@angular * 5)
    @angle %= 360
    @x += @velocity_x
    @y += @velocity_y

    if @x > 10_000
      @x = 0
    elsif @x < 0
      @x = 10_000
    end
    if @y > 10_000
      @y = 0
    elsif @y < 0
      @y = 10_000
    end

      # :drift => 0, 
      # :thrust => 1, 
      # :drift_left => 2
      # :thrust_left => 3,
      # :thrust_right => 4,
      # :drift_right => 5}

    frame_name = if @thruster
      if @angular > 0
        :thrust_right
      elsif @angular < 0
        :thrust_left
      else
        :thrust
      end
    else
      if @angular > 0
        :drift_right
      elsif @angular < 0
        :drift_left
      else
        :drift
      end
    end

    @image = @animation[frame_name]

    if @thruster
      @velocity_x += (Math.sin(Angle.dtor(@angle)) / 10.0) * @speed_factor
      @velocity_y -= (Math.cos(Angle.dtor(@angle)) / 10.0) * @speed_factor
    end

    if Angle.mag(@velocity_x, @velocity_y) > 10 * @speed_factor
      @velocity_x = 0.9 * @velocity_x
      @velocity_y = 0.9 * @velocity_y
    end

    if @reverse
      goal_angle = Angle.reverse_v(@velocity_x, @velocity_y)
      turn_to(goal_angle)
    end

    if @seek && @target
      goal_angle = Angle.vtoa(@target.x - x, @target.y - y)
      turn_to(goal_angle)
    end
  end

  def turn_to(goal_angle)
    if angle_diff(@angle, goal_angle).abs < 5
      @angle = goal_angle
      @angular = 0
    elsif angle_diff(@angle, goal_angle) < 0
      @angular = 1
    else
      @angular = -1
    end
  end
end

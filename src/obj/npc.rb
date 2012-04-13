class Npc < Chingu::GameObject
  include Killable
  include Shipable
  traits :sprite, :timer
  Ships = YAML.load(File.read("data/ships.yml"))
  attr_accessor :angular, :locked, :velocity_x, :velocity_y, :target, :system, :planet
  attr_reader :ship

  class Waypoint < Struct.new(:x, :y); end

  def initialize
    @angular = 0
    @velocity_x, @velocity_y = 0, 0
    self.ship = "wraith"
    super
  end

  def name
    @ship
  end

  def aggro(target)
    Gosu::Song["assets/music/danger.wav"].play(true)
    return if @aggro
    @aggro = true
    @target = target
    @weapons.each_with_index do |w, i|
      every(w.cycle, :name => "fire#{i}") do
        w.fire
      end
    end
  end

  def setup
    self.factor = @attrs["factor"]
  end

  def planet=(planet)
    @planet = planet
    new_target!
  end

  def new_target!
    return if @aggro
    srand
    tx = (rand(2000) - 1000) + @planet.x
    ty = (rand(2000) - 1000) + @planet.y
    @target = Waypoint.new(tx, ty)
    @seek = true
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


  def vx
    @velocity_x
  end

  def vy
    @velocity_y
  end

  def slowdown!
    lock!
    @speed_factor = @base_speed / 2.0
    after(500) do
      @speed_factor = @base_speed
      unlock!
    end
  end

  def angle_diff(a, b)
    ((((a - b) % 360) + 540) % 360) - 180
  end

  def update
    if @target.respond_to?(:health) && @target.health < 0
      @aggro = false
      @weapons.each_with_index do |w, i|
        stop_timer "fire#{i}"
      end
      new_target!
    end
    
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

    if @target && @seek
      goal_angle = Angle.vtoa(@target.x - x, @target.y - y)
      turn_to(goal_angle)
      @thruster = true
      if Gosu.distance(@target.x, @target.y, x, y) < 500
        new_target!
      end
    end
  end

  def turn_to(goal_angle)
    if angle_diff(@angle, goal_angle).abs < 5
      @angle = goal_angle
      @angular = 0
    elsif angle_diff(@angle, goal_angle) < 0
      @angular = @rotation
    else
      @angular = -@rotation
    end
  end
end

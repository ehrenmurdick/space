class Player < Chingu::GameObject
  traits :sprite, :timer
  include Shipable
  include Killable
  attr_accessor :angular, :locked, :velocity_x, :velocity_y, 
      :target, :system, :speed_factor, :thruster, :target_system,
      :fuel, :max_fuel
  attr_reader :ship, :warp_speed

  def initialize
    @angular = 0
    @velocity_x, @velocity_y = 0, 0
    @rocket = Gosu::Sample.new("sounds/rocket.wav")
    self.ship = "scout"
    super
  end

  def dock
    dock = $state.game_objects.select do |o|
      Dock === o
    end.first

    if dock
      if Gosu.distance(@x, @y, dock.x, dock.y) < 100
        @health = @max_health
        @fuel = @max_fuel
      else
        Gosu::Sample.new("sounds/negative.wav").play
      end
    end
  end

  def setup
    self.factor = @attrs["factor"]
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

  def warp
    if @target_system == @system || @target_system.nil?
      Gosu::Sound["negative.wav"]
      return
    end
    Gosu::Sound["charge.wav"].play
    lock!
    @thruster = false
    system = @target_system
    old_system = YAML.load(File.read("data/systems.yml"))[@system]
    new_system = YAML.load(File.read("data/systems.yml"))[system]

    @seek = true
    @target = nil
    @goal_angle = Angle.vtoa(new_system["x"] - old_system["x"], new_system["y"] - old_system["y"])

    after(1000) do
      @speed_factor = 25
      @thruster = true
    end
    after(2300) do
      Gosu::Sound["jump.wav"].play
      new_state = Warp.new(@system, system)
      new_state.player.x = 5000
      new_state.player.y = 5000
      new_state.player.velocity_x = @velocity_x
      new_state.player.velocity_y = @velocity_y
      new_state.player.angle = angle
      new_state.player.ship = ship
      new_state.player.speed_factor = 5
      new_state.player.thruster = true
      new_state.player.fuel = fuel
      $window.switch_game_state(new_state)
    end
  end

  def start_firing
    unless locked
      @weapons.each_with_index do |w, i|
        w.fire
        every(w.cycle, :name => "fire#{i}") do
          w.fire
        end
      end
    end
  end

  def vx
    @velocity_x
  end

  def vy
    @velocity_y
  end

  def next_target
    objs = $state.game_objects.select do |o|
      [Dock, Planet, Npc].include?(o.class)
    end
    return if objs.size == 0
    @target_idx ||= objs.index(@target) || 0
    @target_idx += 1
    @target_idx %= objs.size
    @target = objs[@target_idx]
  end

  def halt_fire
    @weapons.each_with_index do |w, i|
      stop_timer "fire#{i}"
    end
  end

  def slowdown!
    lock!
    @speed_factor = @base_speed / 2.0
    after(500) do
      @speed_factor = @base_speed
      unlock!
    end
  end

  def turn_left
    return if locked
    @angular = -@rotation
  end

  def turn_right
    return if locked
    @angular = @rotation
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

  def update
    @angle += (@angular * 5)
    @angle %= 360
    @x += @velocity_x
    @y += @velocity_y

    if @x > 10_000 - 640
      @x = 640
    elsif @x < 640
      @x = 10_000 - 640
    end
    if @y > 10_000 - 480
      @y = 480
    elsif @y < 480
      @y = 10_000 - 480
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

    a, b = accel_vector
    @velocity_x += a
    @velocity_y -= b

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

    if @seek && @goal_angle
      turn_to(@goal_angle)
    end
  end
end

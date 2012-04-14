module Shipable
  Ships = YAML.load(File.read("data/ships.yml"))
  def ship=(name)
    @ship = name
    @attrs = Ships[name]
    @animation = Chingu::Animation.new(:file => @attrs["animation"]) 
    @animation.frame_names = @attrs["frames"]
    @frame_name = "drift"
    @max_fuel = @attrs["fuel"]
    @fuel = @attrs["fuel"]

    if @attrs["weapons"]
      @weapons = @attrs["weapons"].map do |w|
        w = eval(w["type"]).new(self, w["x"], w["y"])
      end
    end

    @health = @max_health = @attrs["health"]


    @rotation = @attrs["rotation"]
    @warp_speed = @attrs["warp_speed"]

    @base_speed = @attrs["base_speed"]

    @speed_factor = @base_speed
    self.factor = @attrs["factor"]
  end

  def arm(idx)
    return unless w = @weapons[idx]
    w.armed = !w.armed
  end

  def accel_vector
    if @thruster
      [(Math.sin(Angle.dtor(@angle)) / 10.0) * @speed_factor,
      (Math.cos(Angle.dtor(@angle)) / 10.0) * @speed_factor]
    else
      [0, 0]
    end
  end

  def turn_to(goal_angle)
    if Angle.diff(@angle, goal_angle).abs < 5
      @angle = goal_angle
      @angular = 0
    elsif Angle.diff(@angle, goal_angle) < 0
      @angular = @rotation
    else
      @angular = -@rotation
    end
  end
end

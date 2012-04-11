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
        eval(w["type"]).new(self, w["x"], w["y"])
      end
    end

    @health = @max_health = @attrs["health"]


    @rotation = @attrs["rotation"]
    @warp_speed = @attrs["warp_speed"]

    @base_speed = @attrs["base_speed"]

    @speed_factor = @base_speed
    self.factor = @attrs["factor"]
  end
end

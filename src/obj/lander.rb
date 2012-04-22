class Lander < Player
  class Shadow < Chingu::GameObject
    trait :sprite

    def initialize
      super :image => "assets/shadow.png"
    end
  end

  class OffsetShip < Chingu::GameObject
    trait :sprite
  end

  attr_accessor :alt, :shadow, :g, :vz, :offset

  def setup
    self.g = 0.1
    self.x = 2500
    self.y = 2500
    self.vz = 0
    self.alt = 500
    self.velocity_x = 0
    self.velocity_y = 0
    self.angle = 0
    self.ship = 'scout'
    self.factor = @attrs["factor"]
    self.shadow = Shadow.create
    self.shadow.scale = 0.7
    self.offset = OffsetShip.create
  end

  def locked
    alt == 0
  end

  def draw
  end

  def boost
    @booster = true
    @rb = @rocket.play
    every(9000, :name => "engine") do
      @rb && @rb.stop
      @rb = @rocket.play
    end
  end

  def halt_boost
    @booster = false
    stop_timer "engine"
    @rb && @rb.stop
  end

  def update
    super
    offset.image = image
    offset.x = x
    offset.y = y - (alt / 5.0)
    offset.angle = self.angle
    self.alt -= vz
    if self.alt < 0
      self.alt = 0
      self.vz = 0
    end

    if self.vz > 2
      self.vz = 2
    end
    self.vz += g
    shadow.x = x
    shadow.y = y + (alt/2.0) + 10
    if @booster
      self.vz -= 0.2
    end

    if alt == 0
      @velocity_x = 0.95 * @velocity_x
      @velocity_y = 0.95 * @velocity_y
    else
      @velocity_x = 0.99 * @velocity_x
      @velocity_y = 0.99 * @velocity_y
    end

    if alt > 1500
      $state.takeoff!
      @rb && @rb.stop
    end
  end
end

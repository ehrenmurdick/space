require './src/obj/explosion'
class Asteroid < Chingu::GameObject
  include Killable
  traits :sprite
  attr_accessor :vx, :vy, :am
  def initialize
    super(:image => "assets/asteroid01.png")
  end

  def setup
    self.x = rand(3000) + x - 1500
    self.y = rand(3000) + y - 1500
    self.vx = rand(2) - 1
    self.vy = rand(2) - 1
    self.am = rand(3) - 1.5
    self.zorder = 199
    self.scale = rand(3) + 1
    self.health = self.scale * 10
    cache_bounding_circle
  end

  def position_near(x, y)
    self.x = rand(3000) + x - 1500
    self.y = rand(3000) + y - 1500
  end

  def update
    self.x += vx
    self.y += vy
    self.angle += am
  end
end

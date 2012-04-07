require './src/obj/explosion'
class Asteroid < Chingu::GameObject
  traits :sprite, :collision_detection, :bounding_circle
  attr_accessor :vx, :vy, :am, :health
  def initialize
    super(:image => "assets/asteroid01.png")
  end

  def setup
    self.x = rand(3000) + 4000
    self.y = rand(3000) + 4000
    self.vx = rand(2) - 1
    self.vy = rand(2) - 1
    self.am = rand(3) - 1.5
    self.zorder = 199
    self.scale = rand(3) + 1
    self.health = self.scale * 10
    cache_bounding_circle
  end

  def update
    self.x += vx
    self.y += vy
    self.angle += am
  end

  def hit(power)
    self.health -= power

    if health < 0

      @fireball_animation = Chingu::Animation.new(:file => "assets/explosion.png", :size => [64,64])
      Chingu::Particle.create( :x => x, 
                          :y => y, 
                          :animation => @fireball_animation,
                          :scale_rate => +0.05, 
                          :fade_rate => -10, 
                          :rotation_rate => 0,
                          :mode => :default
                        )
      Gosu::Sound["asteroid_die.wav"].play(0.2)
      destroy
    end
  end
end

module Killable
  def self.included(mod)
    mod.class_eval do
      attr_accessor :health, :max_health
      traits :collision_detection, :bounding_circle
    end
  end

  def hit(power, shooter)
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

    if respond_to?(:aggro)
      aggro(shooter)
    end
  end
end

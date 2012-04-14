class MissileLauncher
  attr_accessor :armed
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @sound = Gosu::Sample.new("sounds/missile.wav")
    @armed = true
  end

  def fire_if_range(range)
    fire if range < 1500 && range > 300
  end

  def fire
    return unless armed
    return unless [Npc, Player].include? @player.target.class
    @sound.play(0.2)
    shot = Missile.create(@player.angle, @player.vx, @player.vy, @player, @player.target)
    x, y = Angle.rotate_v(@player.angle, @x, @y)
    shot.x = @player.x + x
    shot.y = @player.y + y
    shot.angle = @player.angle
  end

  def cycle
    1000
  end
end

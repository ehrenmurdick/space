class MissileLauncher
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @sound = Gosu::Sample.new("sounds/missile.wav")
  end

  def fire
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

class Lasergun
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @sound = Gosu::Sample.new("sounds/laser.wav")
  end

  def fire
    @sound.play
    shot = Laser.create(@player.angle, @player.vx, @player.vy, @player)
    x, y = Angle.rotate_v(@player.angle, @x, @y)
    shot.x = @player.x + x
    shot.y = @player.y + y
    shot.angle = @player.angle
  end

  def cycle
    200
  end
end

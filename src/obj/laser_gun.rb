require './src/obj/laser_turret'
class Lasergun < LaserTurret
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @arc = 20
    @sound = Gosu::Sample.new("sounds/laser.wav")
  end
end

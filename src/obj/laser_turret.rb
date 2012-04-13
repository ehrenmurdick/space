class LaserTurret
  def initialize(player, x, y)
    @player, @x, @y = player, x, y
    @sound = Gosu::Sample.new("sounds/laser.wav")
  end

  def fire
    target = @player.target
    x, y = Angle.rotate_v(@player.angle, @x, @y)
    tx = @player.x + x
    ty = @player.y + y
    range = Gosu.distance(tx, ty, target.x, target.y)

    return unless range < 500
    return unless [Npc, Player].include? target.class
    @sound.play

    lead = range / 12.0

    goal_angle = Angle.vtoa((target.velocity_x * lead) + target.x - tx, 
                            (target.velocity_y * lead) + target.y - ty)

    shot = Laser.create(goal_angle, @player.vx, @player.vy, @player)
    shot.x = @player.x + x
    shot.y = @player.y + y
    shot.angle = goal_angle
  end

  def cycle
    200
  end
end
